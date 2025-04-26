# Create a user called infra_deployer
USER_NAME="infra_deployer"

# Check if the user already exists
aws iam get-user --user-name "$USER_NAME" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "User '$USER_NAME' already exists. Deleting the user..."
    aws iam delete-user --user-name "$USER_NAME" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to delete existing user '$USER_NAME'. Exiting."
        exit 1
    fi
fi

# Create the user
aws iam create-user --user-name "$USER_NAME" > /dev/null 2>&1

# Output the result
if [ $? -eq 0 ]; then
    echo "User '$USER_NAME' created successfully."
else
    echo "Failed to create user '$USER_NAME'."
fi