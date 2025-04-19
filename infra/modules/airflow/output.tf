output "instance_domain" {
  value = "${aws_instance.airflow.public_dns}:8080"
}