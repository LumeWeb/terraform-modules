locals {
  # Get S3 ports by matching just the internal port number
  s3_forwarded_ports = var.network.s3_enabled ? [
    for p in try(module.renterd_deployment.forwarded_ports, []) :
    p.external_port
    if p.port == local.s3_internal_port && upper(p.proto) == "TCP"
  ] : []

  # Safely get the S3 port
  s3_forwarded_port = length(local.s3_forwarded_ports) > 0 ? local.s3_forwarded_ports[0] : null

  # Get the common host
  service_host = module.renterd_deployment.provider_host
}

output "id" {
  description = "The ID of the Renterd Akash deployment"
  value       = module.renterd_deployment.id
}

output "service_endpoints" {
  description = "Renterd service endpoints"
  value       = module.renterd_deployment.service_endpoints
}

output "dns_fqdn" {
  description = "Renterd service FQDN endpoint"
  value       = local.service_fqdn
}

output "s3_fqdn" {
  description = "Renterd S3 FQDN endpoint"
  value       =  local.service_host
}

output "s3_port" {
  description = "Renterd S3 port"
  value       = coalesce(local.s3_forwarded_port, 0)
}

output "provider_host" {
  description = "Provider host for the deployment"
  value       = module.renterd_deployment.provider_host
}

output "forwarded_ports" {
  description = "Forwarded ports for the deployment"
  value       = module.renterd_deployment.forwarded_ports
}

output "port" {
  description = "Forwarded port for the specific service"
  value = coalesce(
    module.renterd_deployment.port,
    0
  )
}