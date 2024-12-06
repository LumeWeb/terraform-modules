locals {
  # Generate unique server IDs for each instance
  master_server_id = 1
  slave_server_ids = {
    for idx in range(var.slave_count) : idx => idx + 2
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

  slave_resources = {
    cpu_units    = coalesce(var.slave_resources.cpu_units, var.default_resources.cpu_units)
    memory_size  = coalesce(var.slave_resources.memory_size, var.default_resources.memory_size)
    memory_unit  = coalesce(var.slave_resources.memory_unit, var.default_resources.memory_unit)
    storage_size = coalesce(var.slave_resources.storage_size, var.default_resources.storage_size)
    storage_unit = coalesce(var.slave_resources.storage_unit, var.default_resources.storage_unit)
  }
}

# Deploy master instance
module "master" {
  source = "../mysql"

  cluster_mode = true

  name = "${var.cluster_name}-master"
  root_password = var.root_password

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
  }

  cluster = {
    enabled = true
    repl_user = var.repl_user
    repl_password = var.repl_password
    server_id = local.master_server_id
  }

  resources = {
    cpu = {
      cores = local.master_resources.cpu_units
    }
    memory = {
      size = local.master_resources.memory_size
      unit = local.master_resources.memory_unit
    }
    storage = {
      size = local.master_resources.storage_size
      unit = local.master_resources.storage_unit
    }
  }

  performance = {
    innodb_buffer_pool_size = var.master_innodb_buffer_pool_size
  }

  placement_attributes = var.master_placement_attributes
  pricing_amount = var.master_pricing_amount
  allowed_providers = var.allowed_providers

  # Tags
  tags = merge(local.common_tags, {
    Role = "master"
  })
}

# Deploy replica instances
module "slaves" {
  source   = "../mysql"
  for_each = local.slave_server_ids

  cluster_mode = true

  name = "${var.cluster_name}-slave-${each.key}"
  root_password = var.root_password

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
  }

  cluster = {
    enabled = true
    repl_user = var.repl_user
    repl_password = var.repl_password
    server_id = each.value
  }

  resources = {
    cpu = {
      cores = local.slave_resources.cpu_units
    }
    memory = {
      size = local.slave_resources.memory_size
      unit = local.slave_resources.memory_unit
    }
    storage = {
      size = local.slave_resources.storage_size
      unit = local.slave_resources.storage_unit
    }
  }

  performance = {
    innodb_buffer_pool_size = var.slave_innodb_buffer_pool_size
  }

  placement_attributes = var.slave_placement_attributes
  pricing_amount = var.slave_pricing_amount
  allowed_providers = var.allowed_providers

  # Tags
  tags = merge(local.common_tags, {
    Role    = "slave"
    SlaveID = each.key
  })

  depends_on = [module.master]
}
