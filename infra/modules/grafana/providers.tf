terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.0.0"
    }
  }
}

provider "grafana" {
  url = "http://${aws_instance.grafana.public_dns}:3000"
  auth = "admin:${var.grafana_admin_password}"
  alias = "grafana_provider"
}