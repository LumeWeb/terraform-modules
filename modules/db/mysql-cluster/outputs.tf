output "master" {
  description = "Master node details"
  value = {
    endpoint = "${module.master.provider_host}:${module.master.port}"
    host     = module.master.provider_host
    port     = module.master.port
    state    = module.master.state
  }
}

output "replicas" {
  description = "Details of replica nodes"
  value = {
    for id, replica in module.replicas : id => {
      endpoint = "${replica.provider_host}:${replica.port}"
      host     = replica.provider_host
      port     = replica.port
      state    = replica.state
    }
  }
}

output "cluster_info" {
  description = "General cluster information"
  value = {
    size = 1 + var.replica_count
    name = var.cluster_name
    environment = var.environment
  }
}
