locals {
  # Generate unique server IDs for each instance
  master_server_id = 1
  replica_server_ids = {
    for idx in range(var.replica_count) : idx => idx + 2
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

  # Compute actual resources to use
  master_resources = {
    cpu_units    = coalesce(var.master_resources.cpu_units, var.default_resources.cpu_units)
    memory_size  = coalesce(var.master_resources.memory_size, var.default_resources.memory_size)
    memory_unit  = coalesce(var.master_resources.memory_unit, var.default_resources.memory_unit)
    storage_size = coalesce(var.master_resources.storage_size, var.default_resources.storage_size)
    storage_unit = coalesce(var.master_resources.storage_unit, var.default_resources.storage_unit)
  }

  replica_resources = {
    cpu_units    = coalesce(var.replica_resources.cpu_units, var.default_resources.cpu_units)
    memory_size  = coalesce(var.replica_resources.memory_size, var.default_resources.memory_size)
    memory_unit  = coalesce(var.replica_resources.memory_unit, var.default_resources.memory_unit)
    storage_size = coalesce(var.replica_resources.storage_size, var.default_resources.storage_size)
    storage_unit = coalesce(var.replica_resources.storage_unit, var.default_resources.storage_unit)
  }
}

# Deploy master instance
module "master" {
  source = "../mysql"

  cluster_mode = true

  # Instance configuration
  server_id         = local.master_server_id
  mysql_port        = var.mysql_port
  root_password     = var.root_password
  repl_user         = var.repl_user
  repl_password     = var.repl_password

  # Metrics configuration
  metrics_enabled = var.metrics_enabled
  metrics_port    = var.metrics_port

  # Etcd configuration
  etc_endpoints = var.etc_endpoints
  etc_username  = var.etc_username
  etc_password  = var.etc_password

  # Resource configuration
  cpu_units    = local.master_resources.cpu_units
  memory_size  = local.master_resources.memory_size
  memory_unit  = local.master_resources.memory_unit
  storage_size = local.master_resources.storage_size
  storage_unit = local.master_resources.storage_unit

  # InnoDB configuration
  innodb_buffer_pool_size = var.master_innodb_buffer_pool_size

  # Akash placement configuration
  placement_strategy_name = "${var.cluster_name}-master"
  placement_attributes    = var.master_placement_attributes
  pricing_amount         = var.master_pricing_amount
  allowed_providers      = var.allowed_providers

  # Tags
  tags = merge(local.common_tags, {
    Role = "master"
  })
}

# Deploy replica instances
module "replicas" {
  source   = "../mysql"
  for_each = local.replica_server_ids

  cluster_mode = true

  # Instance configuration
  server_id     = each.value
  mysql_port    = var.mysql_port
  root_password = var.root_password
  repl_user     = var.repl_user
  repl_password = var.repl_password

  # Metrics configuration
  metrics_enabled = var.metrics_enabled
  metrics_port    = var.metrics_port

  # Etcd configuration
  etc_endpoints = var.etc_endpoints
  etc_username  = var.etc_username
  etc_password  = var.etc_password

  # Resource configuration
  cpu_units    = local.replica_resources.cpu_units
  memory_size  = local.replica_resources.memory_size
  memory_unit  = local.replica_resources.memory_unit
  storage_size = local.replica_resources.storage_size
  storage_unit = local.replica_resources.storage_unit

  # InnoDB configuration
  innodb_buffer_pool_size = var.replica_innodb_buffer_pool_size

  # Akash placement configuration
  placement_strategy_name = "${var.cluster_name}-replica-${each.key}"
  placement_attributes    = var.replica_placement_attributes
  pricing_amount         = var.replica_pricing_amount
  allowed_providers      = var.allowed_providers

  # Tags
  tags = merge(local.common_tags, {
    Role      = "replica"
    ReplicaID = each.key
  })

  depends_on = [module.master]
}
