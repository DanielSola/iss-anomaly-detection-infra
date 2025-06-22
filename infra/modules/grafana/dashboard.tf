resource "grafana_dashboard" "anomaly_dashboard" {
  config_json = file("${path.module}/dashboard.json")
  depends_on  = [null_resource.wait_for_grafana_dashboard]
  provider = grafana.grafana_provider
}

resource "null_resource" "wait_for_grafana_dashboard" {
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

resource "grafana_dashboard_public" "my_public_dashboard" {
  dashboard_uid = grafana_dashboard.anomaly_dashboard.uid
  uid           = "my-custom-public-uid"
  provider = grafana.grafana_provider
  time_selection_enabled = true
  is_enabled             = true
  annotations_enabled    = true
  share                  = "public"
}
