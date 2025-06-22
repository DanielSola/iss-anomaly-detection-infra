terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    grafana = {
      source  = "registry.terraform.io/grafana/grafana"
      version = "3.0.0"
    }
  }
  backend "s3" {
    bucket         = "real-time-anomaly-detection-iss-terraform-state"
    key            = "terraform/state.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = "eu-west-1" # Change to your preferred AWS region
}

module "kinesis" {
  source         = "./modules/kinesis"
  stream_name    = "iss-data-stream"
  aws_account_id = var.aws_account_id
}

module "iss_data_fetcher" {
  source               = "./modules/iss-data-fetcher"
  ami                  = "ami-0fc389ea796968582"
  instance_type        = "t4g.nano"
  key_name             = "manual"
  iam_instance_profile = module.kinesis.ec2_instance_profile_name
}

module "data_bucket" {
  source = "./modules/data-bucket"
  s3_bucket_name = local.s3_bucket_name
}

module "firehose" {
  source                    = "./modules/firehose"
  input_kinesis_stream_arn  = module.kinesis.stream_arn
  input_kinesis_stream_name = module.kinesis.stream_name
  destination_bucket_name   = module.data_bucket.name
  destination_bucket_arn    = module.data_bucket.arn
  aws_account_id            = var.aws_account_id
}

module "airflow" {
  source                = "./modules/airflow"
  ami                   = "ami-0bbd3f89449af0b30"
  instance_type         = "t4g.small"
  airflow_user_password = var.airflow_user_password
  airflow_user_name     = var.airflow_user_name
  aws_account_id        = var.aws_account_id
  s3_bucket_name = local.s3_bucket_name
}

module "grafana" {
  source                 = "./modules/grafana"
  grafana_admin_password = var.grafana_admin_password
  gmail_app_password     = var.gmail_app_password
  aws_account_id         = var.aws_account_id
}

module "iss_telemetry_analyzer_lambda" {
  source = "./modules/iss-telemetry-analyzer-lambda"

  region         = "eu-west-1"
  github_owner   = "DanielSola"
  timeout        = 300
  memory_size    = 128
  kinesis_arn    = module.kinesis.stream_arn
  aws_account_id = var.aws_account_id
  s3_bucket_name = local.s3_bucket_name
}

module "sagemaker" {
  source                  = "./modules/sagemaker"
  sagemaker_endpoint_name = "rcf-anomaly-predictor-endpoint"
}
