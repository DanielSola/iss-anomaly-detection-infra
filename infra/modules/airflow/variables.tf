locals {
  sagemaker_train_dag_path = "${path.module}/dags/sagemaker_train.py"
  merge_data_dag_path      = "${path.module}/dags/merge_data_dag.py"
}

variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "airflow_user_name" {
  description = "The username for Airflow admin user"
  type        = string
}

variable "airflow_user_password" {
  description = "The password for Airflow admin user"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}