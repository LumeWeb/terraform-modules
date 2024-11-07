
output "bus_host" {
  description = "Host address of the bus node"
  value       = module.renterd_bus.provider_host
}

output "worker_hosts" {
  description = "Host addresses of the worker nodes"
  value       = module.renterd_workers[*].provider_host
}

output "autopilot_host" {
  description = "Host address of the autopilot node"
  value       = module.renterd_autopilot.provider_host
}

output "bus_dns_fqdn" {
  description = "DNS FQDN of the bus node"
  value       = module.renterd_bus.dns_fqdn
}

output "worker_dns_fqdns" {
  description = "DNS FQDNs of the worker nodes"
  value       = module.renterd_workers[*].dns_fqdn
}

output "autopilot_dns_fqdn" {
  description = "DNS FQDN of the autopilot node"
  value       = module.renterd_autopilot.dns_fqdn
}

output "bus_id" {
  description = "ID of the bus node"
  value       = module.renterd_bus.id
}

output "worker_ids" {
  description = "IDs of the worker nodes"
  value       = module.renterd_workers[*].id
}

output "autopilot_id" {
  description = "ID of the autopilot node"
  value       = module.renterd_autopilot.id
}

output "bus_port" {
  description = "Port of the bus node"
  value       = module.renterd_bus.port
}

output "worker_ports" {
  description = "Ports of the worker nodes"
  value       = module.renterd_workers[*].port
}

output "autopilot_port" {
  description = "Port of the autopilot node"
  value       = module.renterd_autopilot.port
}