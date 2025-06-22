output "airflow_admin_panel_url" {
  value = module.airflow.instance_domain
}

output "grafana_admin_panel_url" {
  value = module.grafana.admin_panel_url
}

output "grafana_dashboard_public_url" {
  value = module.grafana.dashboard_public_url
}

