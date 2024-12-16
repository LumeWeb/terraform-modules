# Outputs
output "nodes" {
  description = "Details of all cluster nodes"
  value = {
    for id, node in module.nodes : id => {
      endpoint = "${node.provider_host}:${node.port}"
      host     = node.provider_host
      port     = node.port
    }
  }
}

output "cluster_info" {
  description = "General cluster information"
  value = {
    size        = var.node_count
    name        = var.cluster_name
    environment = var.environment
  }
}

output "cluster_prefix" {
  description = "Prefix for etcd keys"
  value = local.etcd_prefix
}