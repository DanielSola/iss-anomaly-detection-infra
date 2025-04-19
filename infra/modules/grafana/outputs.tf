# outputs.tf
output "url" {
  description = "Grafana URL"
  value       = "${aws_instance.grafana.public_dns}:3000"
}
