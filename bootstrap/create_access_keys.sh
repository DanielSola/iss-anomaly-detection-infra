#!/bin/bash

# Check if the required argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <user-name>"
  echo "Example: $0 infra_deployer"
  exit 1
fi

# Define the user name
USER_NAME="$1"

# List all existing access keys for the user
EXISTING_KEYS=$(aws iam list-access-keys --user-name "$USER_NAME" --query "AccessKeyMetadata[].AccessKeyId" --output text)

# Remove all existing access keys
if [ -n "$EXISTING_KEYS" ]; then
  echo "Removing existing access keys for user '$USER_NAME'..."
  for KEY_ID in $EXISTING_KEYS; do
    aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$KEY_ID"
    if [ $? -eq 0 ]; then
      echo "Deleted access key: $KEY_ID"
    else
      echo "Failed to delete access key: $KEY_ID"
    fi
  done
else
  echo "No existing access keys found for user '$USER_NAME'."
fi

# Create new access keys for the user
ACCESS_KEYS=$(aws iam create-access-key --user-name "$USER_NAME" --query "AccessKey" --output json)

# Check if the command was successful
if [ $? -eq 0 ]; then
  # Extract the Access Key ID and Secret Access Key
  ACCESS_KEY_ID=$(echo "$ACCESS_KEYS" | jq -r '.AccessKeyId')
  SECRET_ACCESS_KEY=$(echo "$ACCESS_KEYS" | jq -r '.SecretAccessKey')

  # Output the keys to the screen
  echo "New access keys created successfully for user '$USER_NAME':"
  echo "export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID"
  echo "export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY"
else
  echo "Failed to create new access keys for user '$USER_NAME'."
fi