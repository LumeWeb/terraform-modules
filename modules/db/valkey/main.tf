module "valkey_deployment" {
  source = "../../compute/akash"

  service = {
    name     = var.name
    image    = var.image
    cpu_units = try(var.resources.cpu.cores, 1)
    memory   = {
      value = try(var.resources.memory.size, 1)
      unit = try(var.resources.memory.unit, "Gi")
    }
    storage  = {
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
    env      = merge({
      VALKEY_PORT             = tostring(var.valkey_config.port)
      VALKEY_BIND            = var.valkey_config.bind
      VALKEY_MAXMEMORY       = tostring(var.valkey_config.maxmemory)
      VALKEY_MAXMEMORY_POLICY = var.valkey_config.maxmemory_policy
      VALKEY_APPENDONLY      = var.valkey_config.appendonly ? "yes" : "no"
    }, var.valkey_config.requirepass != "" ? {
      VALKEY_REQUIREPASS = var.valkey_config.requirepass
    } : {}, var.backup_config.enabled ? {
      ENABLE_BACKUP    = "true"
      BACKUP_SCHEDULE  = var.backup_config.schedule
      S3_ENDPOINT     = var.backup_config.s3_endpoint
      S3_ACCESS_KEY   = var.backup_config.s3_access_key
      S3_SECRET_KEY   = var.backup_config.s3_secret_key
      S3_BUCKET       = var.backup_config.s3_bucket
    } : {}, var.metrics_enabled ? {
      METRICS_PASSWORD = var.metrics_password
      METRICS_SERVICE_NAME = var.metrics_service_name
    } : {})
    expose   = [
      {
        port         = var.valkey_config.port
        as          = var.valkey_config.port
        proto       = "tcp"
        global      = true
      }
    ]
  }

  placement_strategy = {
    name       = "${var.name}-placement"
    attributes = var.placement_attributes
    pricing    = {
      denom  = "uakt"
      amount = 1000  # Default pricing, adjust as needed
    }
  }

  allowed_providers = var.allowed_providers
  environment      = var.environment
  tags            = merge(
    var.tags,
    {
      service     = "valkey"
    }
  )
}
