variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "github_owner" {
  description = "GitHub username or organization that owns the repository"
  type        = string
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 300
}

variable "memory_size" {
  description = "Amount of memory in MB for Lambda function"
  type        = number
  default     = 128
}

variable "kinesis_arn" {
  description = "ARN of the Kinesis stream"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "sagemaker_endpoint_name" {
  description = "Name of the SageMaker endpoint"
  type        = string
}