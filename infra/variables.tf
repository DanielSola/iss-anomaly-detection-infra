variable "grafana_admin_password" {
  description = "The admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "airflow_user_password" {
  description = "The user password for Airflow"
  type        = string
  sensitive   = true
}

variable "airflow_user_name" {
  description = "The username for Airflow"
  type        = string
}

variable "notification_sender_app_password" {
  description = "The app password for Gmail"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "terraform_s3_bucket" {
  description = "The S3 bucket for Terraform state"
  type        = string
}

variable "terraform_lock_table" {
  description = "The DynamoDB table for Terraform state locking"
  type        = string
}

variable "notification_sender_email" {
  description = "The email address for sending notifications"
  type        = string
}

variable "notification_receiver_email" {
  description = "The email address for receiving notifications"
  type        = string
}
