variable "sagemaker_endpoint_name" {
  description = "Name of the SageMaker endpoint to delete"
  type        = string
  default     = "my-endpoint"
}

resource "null_resource" "delete_sagemaker_endpoint" {
  triggers = {
    endpoint = var.sagemaker_endpoint_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws sagemaker delete-endpoint --endpoint-name ${self.triggers.endpoint} --region='eu-west-1' || echo 'Endpoint does not exist, skipping deletion.'"
  }
}