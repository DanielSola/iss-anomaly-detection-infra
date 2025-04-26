output "instance_ip" {
  value = module.ec2_instance.instance_ip
}

output "private_key" {
  value     = module.ec2_instance.private_key_pem
  sensitive = true
}

output "airflow_instance_domain" {
  value = module.airflow.instance_domain
}

output "grafana_admin_panel_url" {
  value = module.grafana.admin_panel_url
}
/*
output "grafana_dashboard_public_url" {
  value = module.grafana.dashboard_public_url
}
*/