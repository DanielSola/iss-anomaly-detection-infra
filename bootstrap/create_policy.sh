#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <policy-name> <policy-json-file>"
  echo "Example: $0 handle_tf_state ./policy.json"
  exit 1
fi

# Define the policy name and JSON file
POLICY_NAME="$1"
POLICY_JSON_FILE="$2"

# Check if the policy JSON file exists
if [ ! -f "$POLICY_JSON_FILE" ]; then
  echo "Error: Policy JSON file '$POLICY_JSON_FILE' does not exist."
  exit 1
fi

# Read the policy document from the file
POLICY_DOCUMENT=$(cat "$POLICY_JSON_FILE")

# Check if the policy already exists
EXISTING_POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)

if [ -n "$EXISTING_POLICY_ARN" ]; then
  echo "Policy '$POLICY_NAME' already exists. Deleting it..."

  # List all versions of the policy
  POLICY_VERSIONS=$(aws iam list-policy-versions --policy-arn "$EXISTING_POLICY_ARN" --query "Versions[?IsDefaultVersion==\`false\`].VersionId" --output text)

  # Delete all non-default versions of the policy
  for VERSION_ID in $POLICY_VERSIONS; do
    echo "Deleting policy version: $VERSION_ID"
    aws iam delete-policy-version --policy-arn "$EXISTING_POLICY_ARN" --version-id "$VERSION_ID"
    if [ $? -eq 0 ]; then
      echo "Deleted policy version: $VERSION_ID"
    else
      echo "Failed to delete policy version: $VERSION_ID"
      exit 1
    fi
  done

  # Delete the policy
  aws iam delete-policy --policy-arn "$EXISTING_POLICY_ARN"
  if [ $? -eq 0 ]; then
    echo "Policy '$POLICY_NAME' deleted successfully."
  else
    echo "Failed to delete policy '$POLICY_NAME'. Exiting."
    exit 1
  fi
fi

# Create the policy using AWS CLI
CREATE_POLICY_OUTPUT=$(aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --description "Policy created from file $POLICY_JSON_FILE" \
    --policy-document "$POLICY_DOCUMENT" 2>&1)

# Output the result
if [ $? -eq 0 ]; then
    echo "Policy '$POLICY_NAME' created successfully."
else
    echo "Failed to create policy '$POLICY_NAME'."
    echo "Error: $CREATE_POLICY_OUTPUT"
fi