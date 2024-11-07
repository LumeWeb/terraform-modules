output "master_endpoint" {
  description = "The endpoint of the master MySQL instance"
  value       = "${module.master.provider_host}:${module.master.port}"
}

output "replica_endpoints" {
  description = "Map of replica endpoints by replica ID"
  value = {
    for id, replica in module.replicas : id => "${replica.provider_host}:${replica.port}"
  }
}

output "cluster_size" {
  description = "Total number of instances in the cluster"
  value       = 1 + var.replica_count
}