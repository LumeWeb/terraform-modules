locals {
  # Generate sequential server IDs for each instance
  node_ids = {
    for idx in range(var.node_count) : idx => idx + 1
  }

  # Common tags for all instances
  common_tags = merge(
    var.tags,
    {
      ClusterName = var.cluster_name
      Engine      = "Percona"
      ManagedBy   = "terraform"
    }
  )

  # Compute actual resources to use (same for all nodes)
  node_resources = {
    cpu_units    = coalesce(var.node_resources.cpu_units, var.default_resources.cpu_units)
    memory_size  = coalesce(var.node_resources.memory_size, var.default_resources.memory_size)
    memory_unit  = coalesce(var.node_resources.memory_unit, var.default_resources.memory_unit)
    storage_size = coalesce(var.node_resources.storage_size, var.default_resources.storage_size)
    storage_unit = coalesce(var.node_resources.storage_unit, var.default_resources.storage_unit)
  }

  # Create a prefix for etcd keys
  etcd_prefix = "${var.etc_prefix}/${var.cluster_name}"
}
