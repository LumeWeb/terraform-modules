locals {
  # Default Percona MySQL image
  default_image = "ghcr.io/lumeweb/akash-mysql:develop"

  # Base MySQL environment variables 
  base_env_vars = {
    MYSQL_ROOT_PASSWORD     = var.root_password
    MYSQL_PORT              = var.mysql_port
    SERVER_ID               = var.server_id
    INNODB_BUFFER_POOL_SIZE = var.innodb_buffer_pool_size
  }

  # Add etcd configuration if endpoints are provided
  etcd_env_vars = length(var.etc_endpoints) > 0 ? {
    ETCDCTL_ENDPOINTS = join(",", var.etc_endpoints)
    ETC_USERNAME = var.etc_username
    ETC_PASSWORD = var.etc_password
  } : {}

  # MySQL service configuration
  mysql_service = {
    name      = "mysql"
    image     = local.default_image
    cpu_units = var.cpu_units
    memory = {
      value = var.memory_size
      unit  = var.memory_unit
    }
    storage = {
      persistent_data = {
        size = {
          value = var.storage_size
          unit  = var.storage_unit
        }
        mount = "/var/lib/mysql"
      }
    }
    expose = concat([
      {
        port   = var.mysql_port
        global = true
        proto  = "tcp"
      }
    ],
        var.metrics_enabled ? [
        {
          port   = var.metrics_port
          global = true
          proto  = "tcp"
        }
      ] : []
    )
    env = merge(
      local.base_env_vars,
      local.etcd_env_vars,
        var.metrics_enabled ? {
        METRICS_ENABLED = "1"
        METRICS_PORT    = var.metrics_port
      } : {},
        var.cluster_mode ? {
        CLUSTER_MODE = "true"
      } : {},
      {
        REPL_USER     = var.repl_user
        REPL_PASSWORD = var.repl_password
      }
    )
  }
}

module "mysql_deployment" {
  source = "../../compute/akash"

  service = local.mysql_service

  placement_strategy = {
    name       = var.placement_strategy_name
    attributes = var.placement_attributes
    pricing = {
      denom  = "uakt"
      amount = var.pricing_amount
    }
  }

  allowed_providers = var.allowed_providers

  tags = merge(
    var.tags,
    {
      Service = "MySQL"
      Engine  = "Percona"
    }
  )
}
