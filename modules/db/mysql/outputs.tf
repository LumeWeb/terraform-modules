output "deployment_id" {
  description = "The ID of the MySQL Akash deployment"
  value       = module.mysql_deployment.id
}

output "dns_fqdn" {
  description = "User-provided FQDN for MySQL service"
  value       = module.mysql_deployment.dns_fqdn
}

output "port" {
  description = "Port for the MySQL service"
  value       = module.mysql_deployment.port
}

output "provider_host" {
  description = "Provider host for the MySQL deployment"
  value       = module.mysql_deployment.provider_host
}