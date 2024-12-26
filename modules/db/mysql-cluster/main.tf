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

# Deploy cluster nodes
module "nodes" {
  source   = "../mysql"
  for_each = local.node_ids

  cluster_mode = true

  name = "${var.cluster_name}-node-${each.key}"
  root_password = var.root_password
  environment = var.environment

  backups_enabled = var.backups_enabled

  network = {
    mysql_port = var.mysql_port
  }

  metrics = {
    enabled = var.metrics_enabled
    port = var.metrics_port
  }

  etcd = {
    endpoints = var.etc_endpoints
    username = var.etc_username
    password = var.etc_password
    prefix = local.etcd_prefix
  }

  cluster = {
    enabled = true
    repl_user = var.repl_user
    repl_password = var.repl_password
    server_id = each.value
  }

  resources = {
    cpu = {
      cores = local.node_resources.cpu_units
    }
    memory = {
      size = local.node_resources.memory_size
      unit = local.node_resources.memory_unit
    }
    storage = {
      size = local.node_resources.storage_size
      unit = local.node_resources.storage_unit
    }
  }

  performance = {
    innodb_buffer_pool_size = var.innodb_buffer_pool_size
  }

  placement_attributes = var.placement_attributes
  pricing_amount = var.pricing_amount
  allowed_providers = var.allowed_providers

  # Tags
  tags = merge(local.common_tags, {
    Role    = "node"
    NodeID  = each.key
  })

  service_expose = concat(
    [
      {
        port   = var.mysql_port
        as     = var.mysql_port
        global = true
        proto  = "tcp"
      }
    ],
      var.metrics_enabled ? [
      {
        port   = 8080
        as     = 8080
        global = true
        proto  = "tcp"
      }
    ] : []
  )
}
