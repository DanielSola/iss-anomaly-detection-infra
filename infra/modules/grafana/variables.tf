variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "gmail_app_password" {
    description = "Gmail app password for notifications"
    type        = string
    sensitive   = true
}

variable "aws_account_id" {
    description = "AWS account ID"
    type        = string
}