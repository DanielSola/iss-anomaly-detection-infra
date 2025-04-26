#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <policy-name> <user-name>"
  echo "Example: $0 handle_tf_state infra_deployer"
  exit 1
fi

# Define the policy name and user name
POLICY_NAME="$1"
USER_NAME="$2"

# Get the ARN of the policy
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)

if [ -z "$POLICY_ARN" ]; then
  echo "Policy '$POLICY_NAME' does not exist. Please create it first."
  exit 1
fi

# Attach the policy to the user
ATTACH_OUTPUT=$(aws iam attach-user-policy --user-name "$USER_NAME" --policy-arn "$POLICY_ARN" 2>&1)

# Output the result
if [ $? -eq 0 ]; then
  echo "Policy '$POLICY_NAME' attached to user '$USER_NAME' successfully."
else
  echo "Failed to attach policy '$POLICY_NAME' to user '$USER_NAME'."
  echo "Error: $ATTACH_OUTPUT"
fi