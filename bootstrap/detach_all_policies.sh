#!/bin/bash

# Check if the required argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <user-name>"
  echo "Example: $0 infra_deployer"
  exit 1
fi

# Define the user name
USER_NAME="$1"

# List all attached policies for the user
ATTACHED_POLICIES=$(aws iam list-attached-user-policies --user-name "$USER_NAME" --query "AttachedPolicies[].PolicyArn" --output text)

# Check if there are any attached policies
if [ -z "$ATTACHED_POLICIES" ]; then
  echo "No policies are attached to user '$USER_NAME'."
  exit 0
fi

# Detach all attached policies
echo "Detaching all policies from user '$USER_NAME'..."
for POLICY_ARN in $ATTACHED_POLICIES; do
  echo "Detaching policy: $POLICY_ARN"
  aws iam detach-user-policy --user-name "$USER_NAME" --policy-arn "$POLICY_ARN"
  if [ $? -eq 0 ]; then
    echo "Successfully detached policy: $POLICY_ARN"
  else
    echo "Failed to detach policy: $POLICY_ARN"
  fi
done

echo "All policies detached from user '$USER_NAME'."