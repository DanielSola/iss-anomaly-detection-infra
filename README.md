# iss-anomaly-detection-infra
## Overview

Terraform infrastructure to deploy a cloud-based anomaly detection system for monitoring International Space Station telemetry data.

This repository contains Terraform configuration files to deploy an anomaly detection system in AWS that monitors the ISS Loop A cooling system variables (pressure, temperature, flowrate) using a Random Cut Forest algorithm.

The system includes:
- Airflow for pipeline orchestration
- Grafana monitoring dashboard
- Email notifications via Gmail for detected anomalies

**Estimated monthly cost: ~150€**

## Prerequisites

- Terraform 1.10.5 or latest compatible version
- AWS user with administrator permissions
- AWS credentials configured locally

## Setup Instructions

### 1. Configure AWS Credentials
```bash
export AWS_ACCESS_KEY_ID=*your key*
export AWS_SECRET_ACCESS_KEY=*your key*
```

### 2. Create Backend Resources
- Create an S3 bucket for Terraform state storage
- Create a DynamoDB table for Terraform state locking

### 3. Configure Backend
Set backend configuration in `backend.config`:
```hcl
bucket         = "your unique bucket name"
key            = "terraform/state.tfstate"
region         = "your aws region"
encrypt        = true
dynamodb_table = "your table name"
```

### 4. Deploy Infrastructure
```bash
cd ./infra
terraform init --backend-config=backend.config
terraform apply
```

## Required Variables

| Variable | Description | Type | Sensitive |
|----------|-------------|------|-----------|
| `grafana_admin_password` | The admin password for Grafana | string | Yes |
| `airflow_user_password` | The user password for Airflow | string | Yes |
| `airflow_user_name` | The username for Airflow | string | No |
| `notification_sender_app_password` | The app password for Gmail | string | Yes |
| `notification_sender_email` | The email address for sending notifications | string | No |
| `notification_receiver_email` | The email address for receiving notifications | string | No |
| `aws_account_id` | The AWS account ID | string | No |
| `aws_region` | The AWS region | string | No |
| `terraform_s3_bucket` | The S3 bucket for Terraform state | string | No |
| `terraform_lock_table` | The DynamoDB table for Terraform state locking | string | No |

## Outputs

After deployment, you'll receive the following URLs:

```
airflow_admin_panel_url = "URL to access the Airflow web interface for pipeline management"
grafana_admin_panel_url = "URL to access the Grafana admin panel for dashboard configuration"
grafana_dashboard_public_url = "Public URL to view the anomaly detection monitoring dashboard"
```

## Teardown

To remove all deployed infrastructure and avoid ongoing costs:

```bash
cd ./infra
terraform destroy
```

**Warning:** This will permanently delete all resources including:
- EC2 instances and associated storage
- S3 buckets and their contents
- CloudWatch logs and metrics
- All monitoring data and configurations

Make sure to backup any important data before running the destroy command.