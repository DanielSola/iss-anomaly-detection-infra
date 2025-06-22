variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "notification_sender_email" {
  description = "Gmail address for sending notifications"
  type        = string
}

variable "notification_sender_app_password" {
  description = "Gmail app password for notifications"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "notification_receiver_email" {
  description = "Email address for receiving notifications"
  type        = string
}
