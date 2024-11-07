output "dseq" {
  description = "Deployment sequence number"
  value       = module.etcd_deployment.dseq
}

output "provider_host" {
  description = "Provider host for the deployment"
  value       = module.etcd_deployment.provider_host
}

output "forwarded_ports" {
  description = "Forwarded ports for the deployment"
  value       = module.etcd_deployment.forwarded_ports
}

output "port" {
  description = "Port for the service"
  value       = module.etcd_deployment.port
}


