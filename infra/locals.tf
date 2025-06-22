resource "random_uuid" "bucket_suffix" {}

locals {
  # Combine prefix with uuid for unique bucket names
  s3_bucket_name = "iss-historical-data-${substr(random_uuid.bucket_suffix.result, 0, 8)}"
}
