output "dns_fqdn" {
  description = "Grafana DNS FQDN"
  value       =  module.grafana_deployment.dns_fqdn
}

output "port" {
  description = "Port for the Grafana service"
  value       = module.grafana_deployment.port
}

output "provider_host" {
  description = "Provider host for the Grafana deployment"
  value       = module.grafana_deployment.provider_host
}