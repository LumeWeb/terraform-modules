output "id" {
  description = "The ID of the Renterd Akash deployment"
  value       = module.renterd_deployment.id
}

output "service_endpoints" {
  description = "Renterd service endpoints"
  value       = module.renterd_deployment.service_endpoints
}

output "renterd_endpoint" {
  description = "Renterd service FQDN endpoint"
  value       = local.service_fqdn
}

output "renterd_s3_endpoint" {
  description = "Renterd S3 FQDN endpoint"
  value       = local.s3_fqdn
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

output "service_states" {
  description = "States of dependent services"
  value = {
    renterd = module.renterd_deployment.id
  }
}
