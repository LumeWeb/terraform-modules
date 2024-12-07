output "deployment" {
  description = "ETCD deployment details"
  value = {
    id            = module.etcd_deployment.id
    dseq          = module.etcd_deployment.dseq
    provider_host = module.etcd_deployment.provider_host
    port          = module.etcd_deployment.port
    state         = module.etcd_deployment.state
  }
}

output "service" {
  description = "ETCD service details"
  value = {
    client_port  = module.etcd_deployment.port
    peer_port    = var.ports.peer
    metrics_port = var.ports.metrics
    endpoints    = [
      "${module.etcd_deployment.provider_host}:${module.etcd_deployment.port}"
    ]
  }
}

output "cluster" {
  description = "ETCD cluster information"
  value = {
    name      = var.name
    enabled   = var.cluster_enabled
    peers     = var.cluster_peers
    environment = var.environment
  }
}


