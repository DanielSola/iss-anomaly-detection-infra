resource "grafana_dashboard" "anomaly_dashboard" {
  config_json = file("${path.module}/dashboard.json")
  depends_on  = [null_resource.wait_for_grafana_dashboard]
}

resource "null_resource" "wait_for_grafana_dashboard" {
  provisioner "local-exec" {
    command = <<EOT
      for i in {1..10}; do
        curl --fail http://${aws_instance.grafana.public_dns}:3000/api/health && exit 0 || echo "Retrying in 10 seconds..."
        sleep 10
      done
      exit 1
    EOT
  }

  depends_on = [aws_instance.grafana]
}