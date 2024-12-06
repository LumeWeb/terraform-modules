output "master" {
  description = "Master node details"
  value = {
    endpoint = "${module.master.provider_host}:${module.master.port}"
    host     = module.master.provider_host
    port     = module.master.port
    state    = module.master.state
  }
}

output "slaves" {
  description = "Details of slave nodes"
  value = {
    for id, slave in module.slaves : id => {
      endpoint = "${slave.provider_host}:${slave.port}"
      host     = slave.provider_host
      port     = slave.port
      state    = slave.state
    }
  }
}

output "cluster_info" {
  description = "General cluster information"
  value = {
    size = 1 + var.slave_count
    name = var.cluster_name
    environment = var.environment
  }
}
