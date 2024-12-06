
output "bus" {
  description = "Bus node details"
  value = {
    id         = module.renterd_bus.id
    host       = module.renterd_bus.provider_host
    port       = module.renterd_bus.port
    dns_fqdn   = module.renterd_bus.dns_fqdn
  }
}

output "workers" {
  description = "Worker nodes details"
  value = [
    for i, worker in module.renterd_workers : {
      id         = worker.id
      host       = worker.provider_host
      port       = worker.port
      dns_fqdn   = worker.dns_fqdn
      worker_id  = "worker-${i + 1}"
    }
  ]
}

output "autopilot" {
  description = "Autopilot node details"
  value = {
    id         = module.renterd_autopilot.id
    host       = module.renterd_autopilot.provider_host
    port       = module.renterd_autopilot.port
    dns_fqdn   = module.renterd_autopilot.dns_fqdn
  }
}

output "cluster_info" {
  description = "General cluster information"
  value = {
    worker_count = var.worker_count
    environment  = var.environment
    base_domain  = var.base_domain
  }
}
