locals {
  # 1. Base configuration
  base_config = {
    name = coalesce(var.name, "mysql")
    image = coalesce(var.image, "ghcr.io/lumeweb/akash-mysql:develop")
    cpu_units = var.resources.cpu.cores
    memory = {
      value = var.resources.memory.size
      unit  = var.resources.memory.unit
    }
  }

  # 2. Storage configuration
  storage_config = {
    root = {
      size = {
        value = var.resources.storage.size
        unit  = var.resources.storage.unit
      }
    }
    persistent_data = {
      size = {
        value = var.resources.persistent_storage.size
        unit  = var.resources.persistent_storage.unit
      }
      mount     = "/var/lib/mysql"
      class     = var.resources.persistent_storage.class
      read_only = false
    }
  }

  # 3. Environment variables - Core MySQL
  base_env_vars = {
    MYSQL_ROOT_PASSWORD     = var.root_password
    MYSQL_PORT              = var.network.mysql_port
    INNODB_BUFFER_POOL_SIZE = var.performance.innodb_buffer_pool_size
    BACKUP_ENABLED          = var.backups_enabled
    CLUSTER_MODE            = var.cluster_mode
  }

  # Component-specific env vars
  component_env_vars = {
    # ETCD integration
    etcd = length(var.etcd.endpoints) > 0 ? {
      ETCDCTL_ENDPOINTS = join(",", var.etcd.endpoints)
      ETC_USERNAME = var.etcd.username
      ETC_PASSWORD = var.etcd.password
      ETC_PREFIX   = var.etcd.prefix
    } : {}

    # Metrics configuration
    metrics = var.metrics.enabled ? {
      METRICS_ENABLED = "1"
      METRICS_PORT = tostring(var.metrics.port)
    } : {}

    # Cluster configuration
    cluster = var.cluster.enabled ? {
      CLUSTER_MODE        = "true"
      MYSQL_REPL_USERNAME = var.cluster.repl_user
      MYSQL_REPL_PASSWORD = var.cluster.repl_password
    } : {}
  }

  # Merge all environment variables
  service_env_vars = merge(
    local.base_env_vars,
    local.component_env_vars.etcd,
    local.component_env_vars.metrics,
    local.component_env_vars.cluster
  )

  # 4. Service expose configuration
  service_expose = concat(
    # Main MySQL port
    [
      {
        port   = var.network.mysql_port
        global = true
        proto  = "tcp"
      }
    ],
    # Optional metrics port
      var.metrics.enabled ? [
      {
        port   = var.metrics.port
        global = true
        proto  = "tcp"
      }
    ] : []
  )

  # 5. Final service configuration
  service_config = {
    name      = local.base_config.name
    image     = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory    = local.base_config.memory
    storage   = local.storage_config
    env       = local.service_env_vars
    expose    = local.service_expose
  }

  # 6. Standard tags
  common_tags = merge(
    var.tags,
    {
      Service   = "MySQL"
      Engine    = "Percona"
      Role      = var.cluster.enabled ? "cluster-node" : "standalone"
      Component = "database"
      ManagedBy = "terraform"
    }
  )
}

module "mysql_deployment" {
  source = "../../compute/akash"

  service = local.service_config

  placement_strategy = {
    name       = "${var.name}-placement"
    attributes = var.placement_attributes
    pricing = {
      denom  = "uakt"
      amount = var.pricing_amount
    }
  }

  allowed_providers = var.allowed_providers
  environment       = var.environment
  tags              = local.common_tags
}
