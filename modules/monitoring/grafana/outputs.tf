output "deployment_id" {
  description = "The ID of the Grafana Akash deployment"
  value       = module.grafana_deployment.id
}

output "service_endpoints" {
  description = "Map of Grafana service endpoints"
  value       = module.grafana_deployment.service_endpoints
}

output "grafana_url" {
  description = "URL to access Grafana UI"
  value       = "https://${var.dns.domain}"
}

output "admin_user" {
  description = "Grafana admin username"
  value       = var.admin_user
}

output "state" {
  description = "Current state of the Grafana deployment"
  value       = module.grafana_deployment.state
}
