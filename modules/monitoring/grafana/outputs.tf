output "dns_fqdn" {
  description = "Grafana DNS FQDN"
  value       =  module.grafana_deployment.dns_fqdn
}