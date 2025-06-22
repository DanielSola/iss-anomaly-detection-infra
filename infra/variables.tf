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

variable "gmail_app_password" {
  description = "The app password for Gmail"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

