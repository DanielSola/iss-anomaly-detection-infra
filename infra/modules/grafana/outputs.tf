output "admin_panel_url" {
  description = "Grafana panel URL"
  value       = aws_cloudfront_distribution.grafana.domain_name
}


output "dashboard_public_url" {
  description = "Grafana panel URL"
  value       = "${aws_cloudfront_distribution.grafana.domain_name}/public-dashboards/${grafana_dashboard_public.my_public_dashboard.access_token}"
}

