locals {
  # Base configuration
  base_config = {
    name = var.name
    image = var.image
    cpu_units = try(var.resources.cpu.cores, 1)
    memory = {
      value = try(var.resources.memory.size, 1)
      unit = try(var.resources.memory.unit, "Gi")
    }
  }

  # Storage configuration
  storage_config = {
    root = {
      size = {
        value = try(var.resources.storage.size, 1)
        unit = try(var.resources.storage.unit, "Gi")
      }
    }
    persistent_data = try(var.resources.persistent_storage, null) != null ? {
      size = {
        value = var.resources.persistent_storage.size
        unit = var.resources.persistent_storage.unit
      }
      mount = var.resources.persistent_storage.mount
      class = var.resources.persistent_storage.class
    } : null
  }

  # Environment variables
  base_env_vars = {
    VALKEY_PORT             = tostring(var.valkey_config.port)
    VALKEY_BIND            = var.valkey_config.bind
    VALKEY_MAXMEMORY       = tostring(var.valkey_config.maxmemory)
    VALKEY_MAXMEMORY_POLICY = var.valkey_config.maxmemory_policy
    VALKEY_APPENDONLY      = var.valkey_config.appendonly ? "yes" : "no"
  }

  # Add password if set
  env_with_password = var.valkey_config.requirepass != "" ? merge(local.base_env_vars, {
    VALKEY_REQUIREPASS = var.valkey_config.requirepass
  }) : local.base_env_vars

  # Add backup configuration if enabled
  env_with_backup = var.backup_config.enabled ? merge(local.env_with_password, {
    ENABLE_BACKUP    = "true"
    BACKUP_SCHEDULE  = var.backup_config.schedule
    S3_ENDPOINT     = var.backup_config.s3_endpoint
    S3_ACCESS_KEY   = var.backup_config.s3_access_key
    S3_SECRET_KEY   = var.backup_config.s3_secret_key
    S3_BUCKET       = var.backup_config.s3_bucket
  }) : local.env_with_password

  # Metrics environment variables
  metrics_env_vars = var.metrics_enabled ? {
    METRICS_PASSWORD = var.metrics_password
    METRICS_SERVICE_NAME = var.metrics_service_name
  } : {}

  # Service expose configuration
  service_expose = concat(
    [
      {
        port         = var.valkey_config.port
        as          = var.valkey_config.port
        proto       = "tcp"
        global      = true
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

  # Final service configuration
  service_config = {
    name     = local.base_config.name
    image    = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory   = local.base_config.memory
    storage  = local.storage_config
    env      = merge(local.env_with_backup, local.metrics_env_vars)
    expose   = local.service_expose
  }

  # Tags
  common_tags = {
    service     = "valkey"
  }
}
