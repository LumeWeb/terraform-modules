locals {
  etcd_prefix = format("%s/%s", var.etcd.prefix, var.name)
  # Base configuration
  base_config = {
    name  = var.name
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
    PORTAL__CORE__DOMAIN      = var.domain
    PORTAL__CORE__PORTAL_NAME = var.portal_name
    PORTAL__CORE__PORT = tostring(var.port)

    # Mail
    PORTAL__CORE__MAIL__HOST     = var.mail.host
    PORTAL__CORE__MAIL__USERNAME = var.mail.username
    PORTAL__CORE__MAIL__PASSWORD = var.mail.password
    PORTAL__CORE__MAIL__FROM     = var.mail.from
    PORTAL__CORE__MAIL__SSL = var.mail.ssl ? "true" : "false"

    # S3 Storage
    PORTAL__CORE__STORAGE__S3__BUFFER_BUCKET = var.storage.s3.buffer_bucket
    PORTAL__CORE__STORAGE__S3__ENDPOINT      = var.storage.s3.endpoint
    PORTAL__CORE__STORAGE__S3__REGION        = var.storage.s3.region
    PORTAL__CORE__STORAGE__S3__ACCESS_KEY    = var.storage.s3.access_key
    PORTAL__CORE__STORAGE__S3__SECRET_KEY = var.storage.s3.secret_key

    # Sia Storage
    PORTAL__CORE__STORAGE__SIA__KEY     = var.storage.sia.key
    PORTAL__CORE__STORAGE__SIA__CLUSTER = var.storage.sia.cluster ? "true" : "false"
    PORTAL__CORE__STORAGE__SIA__URL = var.storage.sia.url

    # Database
    PORTAL__CORE__DB__TYPE = var.database.type

    # Redis
    PORTAL__CORE__CLUSTERED__REDIS__ADDRESS = var.redis.address
    PORTAL__CORE__CLUSTERED__REDIS__PASSWORD = var.redis.password

    # Etcd
    PORTAL__CORE__CLUSTERED__ETCD__ENDPOINTS = join(",", var.etcd.endpoints)
    PORTAL__CORE__CLUSTERED__ETCD__USERNAME = var.etcd.username
    PORTAL__CORE__CLUSTERED__ETCD__PASSWORD = var.etcd.password
    PORTAL__CORE__CLUSTERED__ETCD__PREFIX = local.etcd_prefix

    # Cluster
    PORTAL__CORE__CLUSTERED__ENABLED = var.cluster ? "true" : "false"
  }

  # Add conditional database environment variables
  db_env_vars = var.database.type == "sqlite" ? {
    PORTAL__CORE__DB__FILE = var.database.file
  } : {
    PORTAL__CORE__DB__HOST     = var.database.host
    PORTAL__CORE__DB__PORT = tostring(var.database.port)
    PORTAL__CORE__DB__USERNAME = var.database.username
    PORTAL__CORE__DB__PASSWORD = var.database.password
    PORTAL__CORE__DB__NAME     = var.database.name
  }

  # Final environment variables including extras
  final_env_vars = merge(local.base_env_vars, local.db_env_vars, var.extra_env_vars)

  # Service expose configuration
  service_expose = [
    {
      port   = 80
      as     = 80
      global = true
      ip     = "default"
    },
    {
      port = 443
      as   = 443
      global = true
      ip   = "default"
    }
  ]

  # Final service configuration
  service_config = {
    name      = local.base_config.name
    image     = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory    = local.base_config.memory
    env       = local.final_env_vars
    expose    = local.service_expose
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
      service     = "portal"
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
    name       = "${var.name}-placement"
    attributes = var.placement_attributes
    pricing = {
      denom  = "uakt"
      amount = 1000  # Adjust as needed
    }
  }

  allowed_providers = var.allowed_providers
  environment       = var.environment
  tags              = local.common_tags
}
