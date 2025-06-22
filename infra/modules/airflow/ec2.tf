
resource "aws_instance" "airflow" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = "manual"
  security_groups        = [aws_security_group.airflow_sg.name]  # Reference the security group
  iam_instance_profile   = aws_iam_instance_profile.airflow_profile.name  # Reference the IAM instance profile
  
  tags = {
    Name = "airflow"
  }

  user_data = <<-EOF
#!/bin/bash
# Update and install minimal dependencies
sudo apt-get update -y
sudo apt-get install -y python3-pip python3-dev libpq-dev python3-virtualenv unzip pkg-config --no-install-recommends

# Upgrade pip and install wheel to reduce compilation
pip install --no-cache-dir --upgrade pip wheel

# Create a virtual environment and activate it
cd /home/ubuntu
virtualenv airflow-venv
source airflow-venv/bin/activate

# Install Apache Airflow with the specified version
pip install --no-cache-dir "apache-airflow==2.10.5" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.10.5/constraints-3.8.txt"
pip install --no-cache-dir apache-airflow-providers-amazon
pip install --no-cache-dir pandas
pip install --no-cache-dir scikit-learn

# Set AWS account ID environment variable
export AWS_ACCOUNT_ID=${var.aws_account_id}
export S3_BUCKEt_NAME=${var.s3_bucket_name}

# Initialize the Airflow database
airflow db init

# Create an admin user for Airflow
airflow users create \
  --username ${var.airflow_user_name} \
  --password ${var.airflow_user_password} \
  --firstname FirstName \
  --lastname LastName \
  --email user@example.com \
  --role Admin

# Instal AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Get DAGs from S3 bucket
mkdir -p /home/ubuntu/airflow/dags
aws s3 sync s3://airflow-iss-anomaly-detector/airflow/dag/ /home/ubuntu/airflow/dags/
export AIRFLOW__CORE__DAGS_FOLDER=/home/ubuntu/airflow/dags
export AIRFLOW__CORE__LOAD_EXAMPLES=False
export AWS_REGION=eu-west-1

# Start the Airflow webserver and scheduler as background processes
nohup airflow webserver --port 8080 &
nohup airflow scheduler &

  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "check_airflow" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 90
      for i in {1..20}; do
        curl --fail http://${aws_instance.airflow.public_dns}:8080/health && exit 0 || echo "Retrying in 20 seconds..."
        sleep 10
      done
      exit 1
    EOT
  }

  depends_on = [aws_instance.airflow]
}
