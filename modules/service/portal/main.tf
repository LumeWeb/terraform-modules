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

  # Environment variables
  base_env_vars = {
    # Core
    PORTAL_CORE_DOMAIN = var.domain
    PORTAL_CORE_PORTAL_NAME = var.portal_name
    PORTAL_CORE_PORT = tostring(var.port)

    # Mail
    PORTAL_CORE_MAIL_HOST = var.mail.host
    PORTAL_CORE_MAIL_USERNAME = var.mail.username
    PORTAL_CORE_MAIL_PASSWORD = var.mail.password
    PORTAL_CORE_MAIL_FROM = var.mail.from
    PORTAL_CORE_MAIL_SSL = var.mail.ssl ? "true" : "false"

    # S3 Storage
    PORTAL_CORE_STORAGE_S3_BUFFER_BUCKET = var.storage.s3.buffer_bucket
    PORTAL_CORE_STORAGE_S3_ENDPOINT = var.storage.s3.endpoint
    PORTAL_CORE_STORAGE_S3_REGION = var.storage.s3.region
    PORTAL_CORE_STORAGE_S3_ACCESS_KEY = var.storage.s3.access_key
    PORTAL_CORE_STORAGE_S3_SECRET_KEY = var.storage.s3.secret_key

    # Sia Storage
    PORTAL_CORE_STORAGE_SIA_KEY = var.storage.sia.key
    PORTAL_CORE_STORAGE_SIA_CLUSTER = var.storage.sia.cluster ? "true" : "false"
    PORTAL_CORE_STORAGE_SIA_URL = var.storage.sia.url

    # Database
    PORTAL_CORE_DB_TYPE = var.database.type

    # Redis
    PORTAL_CORE_CLUSTERED_REDIS_ADDRESS = var.redis.address
    PORTAL_CORE_CLUSTERED_REDIS_PASSWORD = var.redis.password

    # Etcd
    PORTAL_CORE_CLUSTERED_ETCD_ENDPOINTS = join(",", var.etcd.endpoints)
    PORTAL_CORE_CLUSTERED_ETCD_USERNAME = var.etcd.username
    PORTAL_CORE_CLUSTERED_ETCD_PASSWORD = var.etcd.password

    # Cluster
    PORTAL_CORE_CLUSTERED_ENABLED = var.cluster ? "true" : "false"
  }

  # Add conditional database environment variables
  db_env_vars = var.database.type == "sqlite" ? {
    PORTAL_CORE_DB_FILE = var.database.file
  } : {
    PORTAL_CORE_DB_HOST = var.database.host
    PORTAL_CORE_DB_PORT = tostring(var.database.port)
    PORTAL_CORE_DB_USERNAME = var.database.username
    PORTAL_CORE_DB_PASSWORD = var.database.password
    PORTAL_CORE_DB_NAME = var.database.name
  }

  # Final environment variables including extras
  final_env_vars = merge(local.base_env_vars, local.db_env_vars, var.extra_env_vars)

  # Service expose configuration
  service_expose = [
    {
      port = 80
      as = 80
      global = true
      to = [{
        ip = "default"
      }]
    },
    {
      port = 443
      as = 443
      to = [{
        ip = "default"
      }]
    }
  ]

  # Final service configuration
  service_config = {
    name = local.base_config.name
    image = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory = local.base_config.memory
    env = local.final_env_vars
    expose = local.service_expose
  }

  # IP Endpoints configuration
  ip_endpoints = {
    default = {
      kind = "ip"
    }
  }

  # Common tags
  common_tags = merge(
    var.tags,
    {
      service = "portal"
      environment = var.environment
    }
  )
}

# Deploy the service using the Akash compute module
module "portal_deployment" {
  source = "../../compute/akash"

  service = local.service_config

  ip_endpoints = local.ip_endpoints

  placement_strategy = {
    name = "${var.name}-placement"
    attributes = var.placement_attributes
    pricing = {
      denom = "uakt"
      amount = 1000  # Adjust as needed
    }
  }

  allowed_providers = var.allowed_providers
  environment = var.environment
  tags = local.common_tags
}
