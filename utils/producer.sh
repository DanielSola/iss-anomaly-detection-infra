#!/bin/bash

STREAM_NAME="iss-data-stream"
REGION="eu-west-1"

# Customizable mean values for each metric
MEAN_FLOWRATE=3000
MEAN_PRESSURE=2100
MEAN_TEMPERATURE=4

while true; do
    TIMESTAMP=$(python3 -c 'from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat(timespec="milliseconds"))')
    
    # Generate random values around the mean for each metric
    FLOWRATE=$((RANDOM % 500 + MEAN_FLOWRATE - 250))
    PRESSURE=$((RANDOM % 200 + MEAN_PRESSURE - 100))
    TEMPERATURE=$((RANDOM % 10 + MEAN_TEMPERATURE - 5))
    
    # Create JSON payloads for each metric
    FLOWRATE_PAYLOAD=$(jq -n \
        --arg name "FLOWRATE" \
        --arg value "$FLOWRATE" \
        --arg timestamp "$TIMESTAMP" \
        '{name: $name, value: $value, timestamp: $timestamp}')
    
    PRESSURE_PAYLOAD=$(jq -n \
        --arg name "PRESSURE" \
        --arg value "$PRESSURE" \
        --arg timestamp "$TIMESTAMP" \
        '{name: $name, value: $value, timestamp: $timestamp}')
    
    TEMPERATURE_PAYLOAD=$(jq -n \
        --arg name "TEMPERATURE" \
        --arg value "$TEMPERATURE" \
        --arg timestamp "$TIMESTAMP" \
        '{name: $name, value: $value, timestamp: $timestamp}')
    
    # Log the updates
    echo "$TIMESTAMP: UPDATE FOR FLOWRATE $FLOWRATE"
    echo "$TIMESTAMP: UPDATE FOR PRESSURE $PRESSURE"
    echo "$TIMESTAMP: UPDATE FOR TEMPERATURE $TEMPERATURE"
    
    # Send each payload to Kinesis
    for PAYLOAD in "$FLOWRATE_PAYLOAD" "$PRESSURE_PAYLOAD" "$TEMPERATURE_PAYLOAD"; do
        RESPONSE=$(aws kinesis put-record \
            --stream-name "$STREAM_NAME" \
            --partition-key "$(echo "$PAYLOAD" | jq -r '.name')" \
            --region "$REGION" \
            --data "$(echo -n "$PAYLOAD" | base64)" 2>&1)
        
        if [[ $? -eq 0 ]]; then
            echo "Kinesis response: $RESPONSE"
        else
            echo "Error sending data to Kinesis: $RESPONSE" >&2
        fi
    done
    
    sleep 3  # Adjust the interval as needed
done
