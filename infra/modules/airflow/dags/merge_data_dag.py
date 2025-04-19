from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import boto3
import json
import csv
import pandas as pd
import pytz
from tabulate import tabulate

# Define S3 client
s3 = boto3.client("s3")
BUCKET_NAME = "iss-historical-data"
CSV_FILENAME = "loop_A_flowrate.csv"
S3_CSV_PATH = "data/loop_A_flowrate.csv"

# Default arguments for the DAG
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2024, 3, 16),
    "retries": 0,
    "retry_delay": timedelta(minutes=5),
}

def get_data():
    now = datetime.utcnow().replace(tzinfo=pytz.utc)
    yesterday = now - timedelta(hours=24)
    
    response = s3.list_objects_v2(Bucket=BUCKET_NAME)
    if "Contents" not in response:
        return []
    
    files = [obj for obj in response["Contents"] if obj["LastModified"] >= yesterday and obj["Key"].endswith("json")]
    all_data = []
    
    for obj in files:
        key = obj["Key"]
        file_obj = s3.get_object(Bucket=BUCKET_NAME, Key=key)
        file_content = file_obj["Body"].read().decode("utf-8")
        fixed_json = "[" + file_content.replace("}{", "},{") + "]"
        
        try:
            parsed_data = json.loads(fixed_json)
            all_data.extend(parsed_data)
        except json.JSONDecodeError as e:
            print(f"Error parsing {key}: {e}")
    
    return all_data

def process_data():
    # Get raw data
    data = get_data()
    
    # Create initial DataFrame
    df = pd.DataFrame(data, columns=['name', 'value', 'timestamp'])
    
    # Convert timestamp to datetime and value to float
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df['value'] = pd.to_numeric(df['value'], errors='coerce')  # Ensure numeric values
    
    # Remove duplicates by taking the last value per timestamp-sensor pair
    df_unique = df.groupby(['timestamp', 'name'])['value'].last().reset_index()
    
    # Pivot to wide format
    df_pivot = df_unique.pivot(columns='name', values='value', index='timestamp').reset_index()
    
    # Forward-fill missing values
    df_pivot = df_pivot.ffill()
        
    # Resample to 1-second intervals (already done in your output, but included for completeness)
    df_pivot.set_index('timestamp', inplace=True)
    df_resampled = df_pivot.resample('2s').ffill().reset_index()
    
    # Calculate rates of change
    df_resampled['Time_Diff'] = df_resampled['timestamp'].diff().dt.total_seconds().fillna(0)
    df_resampled['Flow_Change_Rate'] = df_resampled['FLOWRATE'].diff() / df_resampled['Time_Diff']
    df_resampled['Press_Change_Rate'] = df_resampled['PRESSURE'].diff() / df_resampled['Time_Diff']
    df_resampled['Temp_Change_Rate'] = df_resampled['TEMPERATURE'].diff() / df_resampled['Time_Diff']
    df_resampled.fillna({'Flow_Change_Rate': 0, 'Press_Change_Rate': 0, 'Temp_Change_Rate': 0}, inplace=True)
    
    # Calculate time since last update using raw data
    last_updates = df.groupby('name')['timestamp'].last().to_dict()
        
    # Finalize DataFrame
    df_final = df_resampled.drop(columns=['Time_Diff'])
    df_final = df_final.dropna(subset=['FLOWRATE', 'PRESSURE', 'TEMPERATURE'], how='all')  # Drop rows where all sensors are NaN
    df_final = df_final.drop(columns=['timestamp'], errors='ignore')

    # Save to CSV
    df_final.to_csv(CSV_FILENAME, index=False, header=False)
    
    # Log the final DataFrame
    print('FINAL COLUMNS', df_final.columns)
    print(tabulate(df_final.head(1000), headers='keys', tablefmt='psql'))


def upload_to_s3():
    try:
        s3.upload_file(CSV_FILENAME, BUCKET_NAME, S3_CSV_PATH)
        print(f"File {CSV_FILENAME} uploaded successfully to {BUCKET_NAME}/{S3_CSV_PATH}")
    except Exception as e:
        print(f"Error uploading file to S3: {e}")

with DAG(
    "s3_data_processing",
    default_args=default_args,
    description="Extract, transform, and load data from S3",
    schedule_interval=timedelta(minutes=10),
    catchup=False,
    is_paused_upon_creation=False
) as dag:
    
    task_extract = PythonOperator(
        task_id="extract_data",
        python_callable=get_data,
    )
    
    task_transform = PythonOperator(
        task_id="process_data",
        python_callable=process_data,
    )
    
    task_load = PythonOperator(
        task_id="upload_data",
        python_callable=upload_to_s3,
    )

    task_extract >> task_transform >> task_load