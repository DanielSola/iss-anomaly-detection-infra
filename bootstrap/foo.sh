#!/bin/bash
set -e

./remove_instance_profile.sh EC2InstanceProfile
./remove_instance_profile.sh airflow-instance-profile

./detach_all_policies.sh infra_deployer
./create_policy.sh ManageTerraformState ./policies/ManageTerraformState.json
./create_policy.sh DeployCloudfront ./policies/cloudfront.json
./create_policy.sh DeployLambda ./policies/lambda.json
./create_policy.sh DeployKinesis ./policies/kinesis.json
./create_policy.sh ManageEC2 ./policies/ec2.json
./create_policy.sh ManageIAM ./policies/iam.json
./create_policy.sh ManageDynamoDB ./policies/ManageDynamoDB.json
./create_policy.sh DeleteSagemakerEndpoint ./policies/sagemaker.json
./create_policy.sh ManageS3Buckets ./policies/ManageS3Buckets.json
./create_policy.sh ManageLogGroups ./policies/log_groups.json
./create_policy.sh ManageFirehose ./policies/firehose.json

#./create_policy.sh All ./policies/all.json

./attach_policy.sh ManageTerraformState infra_deployer
./attach_policy.sh DeployCloudfront infra_deployer
./attach_policy.sh DeployLambda infra_deployer
./attach_policy.sh DeployKinesis infra_deployer
./attach_policy.sh ManageEC2 infra_deployer
./attach_policy.sh ManageIAM infra_deployer
./attach_policy.sh ManageS3Buckets infra_deployer
./attach_policy.sh ManageRoles infra_deployer
./attach_policy.sh ManageLogGroups infra_deployer
./attach_policy.sh ManageDynamoDB infra_deployer
./attach_policy.sh ManageFirehose infra_deployer

#./attach_policy.sh All infra_deployer

./create_access_keys.sh infra_deployer