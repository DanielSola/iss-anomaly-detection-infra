#!/bin/bash

# Check if the required argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <instance-profile-name>"
  echo "Example: $0 EC2InstanceProfile"
  exit 1
fi

# Define the instance profile name
INSTANCE_PROFILE_NAME="$1"

# Check if the instance profile exists
INSTANCE_PROFILE_EXISTS=$(aws iam get-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" 2>&1)

if echo "$INSTANCE_PROFILE_EXISTS" | grep -q "NoSuchEntity"; then
  echo "Instance profile '$INSTANCE_PROFILE_NAME' does not exist. Nothing to remove."
  exit 0
fi

# Get the roles attached to the instance profile
ATTACHED_ROLES=$(aws iam get-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" --query "InstanceProfile.Roles[].RoleName" --output text)

# Detach roles from the instance profile
if [ -n "$ATTACHED_ROLES" ]; then
  echo "Detaching roles from instance profile '$INSTANCE_PROFILE_NAME'..."
  for ROLE in $ATTACHED_ROLES; do
    echo "Detaching role: $ROLE"
    aws iam remove-role-from-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" --role-name "$ROLE"
    if [ $? -eq 0 ]; then
      echo "Successfully detached role: $ROLE"
    else
      echo "Failed to detach role: $ROLE"
      exit 1
    fi
  done
else
  echo "No roles attached to instance profile '$INSTANCE_PROFILE_NAME'."
fi

# Delete the instance profile
echo "Deleting instance profile '$INSTANCE_PROFILE_NAME'..."
DELETE_OUTPUT=$(aws iam delete-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" 2>&1)

echo "$DELETE_OUTPUT"

if echo "$DELETE_OUTPUT" | grep -q "NoSuchEntity"; then
  echo "Instance profile '$INSTANCE_PROFILE_NAME' does not exist. Nothing to delete."
  exit 0
elif [ $? -eq 0 ]; then
  echo "Instance profile '$INSTANCE_PROFILE_NAME' deleted successfully."
else
  echo "Failed to delete instance profile '$INSTANCE_PROFILE_NAME'."
  echo "Error: $DELETE_OUTPUT"
  exit 1
fi