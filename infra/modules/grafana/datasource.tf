provider "grafana" {
  url  = "http://${aws_instance.grafana.public_dns}:3000"
  auth = "admin:admin" # Replace with secure credentials (e.g., API key) after initial setup
}

resource "null_resource" "check_grafana" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 60
      for i in {1..20}; do
        curl --fail http://${aws_instance.grafana.public_dns}:3000/api/health && exit 0 || echo "Retrying in 10 seconds..."
        sleep 10
      done
      exit 1
    EOT
  }

  depends_on = [aws_instance.grafana]
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch" # Use 'cloudwatch' for the CloudWatch data source
  name = "CloudWatch"
  uid  = "eej9qve99wbnkd"

  json_data_encoded = jsonencode({
    authType      = "grafana-role" # Use IAM role attached to the EC2 instance
    defaultRegion = "eu-west-1"    # Match your AWS region
  })

  depends_on = [null_resource.check_grafana] # Wait for Grafana to start
}
