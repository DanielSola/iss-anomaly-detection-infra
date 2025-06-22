resource "random_uuid" "suffix" {}

locals {
  # Combine prefix with uuid for unique names
  s3_bucket_name          = "iss-historical-data-${substr(random_uuid.suffix.result, 0, 8)}"
  sagemaker_endpoint_name = "rfc-endpoint-${substr(random_uuid.suffix.result, 0, 8)}"
  terraform_s3_bucket     = var.terraform_s3_bucket
}
