output "deployment_id" {
  description = "The ID of the ProxySQL deployment"
  value       = module.proxysql_deployment.id
}

output "dns_fqdn" {
  description = "User-provided FQDN for ProxySQL service"
  value       = module.proxysql_deployment.dns_fqdn
}

output "provider_host" {
  description = "Provider host for the deployment"
  value       = module.proxysql_deployment.provider_host
}

output "port" {
  description = "Port for the ProxySQL service"
  value       = module.proxysql_deployment.port
}

output "admin_port" {
  description = "Admin port for ProxySQL management"
  value       = var.ports.admin
}

output "state" {
  description = "Current state of the ProxySQL deployment"
  value       = module.proxysql_deployment.state
}
