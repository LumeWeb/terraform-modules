locals {
  # 1. Base configuration
  base_config = {
    name      = var.name
    image     = var.image
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
    persistent_data = try(var.resources.persistent_storage, null) != null ? {
      size = {
        value = var.resources.persistent_storage.size
        unit  = var.resources.persistent_storage.unit
      }
      mount     = var.resources.persistent_storage.mount
      class     = var.resources.persistent_storage.class
      read_only = false
    } : null
  }

  # 3. Environment variables
  base_env_vars = {
    PROXY_ADMIN_PASSWORD = var.admin_password
  }

  component_env_vars = {
    etcd = length(var.etcd.endpoints) > 0 ? {
      ETCDCTL_API         = "3"
      ETCDCTL_ENDPOINTS = join(",", var.etcd.endpoints)
      ETCDCTL_USER        = "${var.etcd.username}:${var.etcd.password}"
      MYSQL_REPL_USERNAME = var.mysql.repl_user
      MYSQL_REPL_PASSWORD = var.mysql.repl_password
    } : {}
  }

  service_env_vars = merge(
    local.base_env_vars,
    local.component_env_vars.etcd
  )

  # 4. Service expose configuration
  service_expose = [
    {
      port   = var.ports.proxy
      as     = var.ports.proxy
      global = true
      proto  = "tcp"
    },
    {
      port   = var.ports.admin
      as     = var.ports.admin
      global = false
      proto  = "tcp"
    }
  ]

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
      Service     = "ProxySQL"
      Component   = "database"
      Role        = "proxy"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  )
}

module "proxysql_deployment" {
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
