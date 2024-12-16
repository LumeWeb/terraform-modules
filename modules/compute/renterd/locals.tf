locals {
  # Common tags for the deployment
  common_tags = merge(
    var.tags,
    {
      Service     = "Renterd"
      Role        = local.is_cluster_mode ? var.mode : "solo"
      ManagedBy   = "terraform"
    }
  )

  # Helper configurations
  is_cluster_mode = var.cluster == true
  proto = coalesce(var.network.enable_ssl, true) ? "https" : "http"
  http_port = coalesce(var.network.enable_ssl, true) ? 80 : coalesce(var.network.http_port, 9980)
  s3_port = coalesce(var.network.enable_ssl, true) ? 80 : coalesce(var.network.s3_port, 8080)

  # Special case: If S3 port is 80, use 9981 internally to avoid port conflicts while maintaining external port 80
  s3_internal_port = local.s3_port == 80 ? 8080 : local.s3_port

  # 1. Base configuration
  base_config = {
    name = local.is_cluster_mode ? (
      var.mode == "bus" ? "${var.name}-bus" :
        var.mode == "worker" ? "${var.name}-worker" :
          var.mode == "autopilot" ? "${var.name}-autopilot" :
          var.name
    ) : "${var.name}-solo"
    image = var.image
    cpu_units = var.resources.cpu.cores
    memory = {
      value = var.resources.memory.size
      unit = var.resources.memory.unit
    }
  }

  # Service FQDN determination
  service_fqdn = var.cluster ? (
    var.mode == "bus" ? "${coalesce(var.dns.bus_prefix, var.name)}.${var.dns.base_domain}" :
      var.mode == "worker" ? "${coalesce(var.dns.worker_prefix, var.name)}.${var.dns.base_domain}" :
        var.mode == "autopilot" ? "${coalesce(var.dns.autopilot_prefix, var.name)}.${var.dns.base_domain}" :
        null
  ) : "${coalesce(var.dns.solo_prefix, var.name)}.${var.dns.base_domain}"

  s3_fqdn = var.network.s3_enabled ? "s3.${local.service_fqdn}" : null

  # Worker address configuration
  worker_external_addr = var.mode == "worker" ? (
    local.service_fqdn != null ?
    "${local.proto}://${local.service_fqdn}/api/worker" :
      try(var.worker_config.external_addr, "") != "" ?
      "${local.proto}://${var.worker_config.external_addr}/api/worker" :
      ""
  ) : ""

  # 2. Storage configuration
  storage_config = {
    root = {
      size = {
        value = var.resources.storage.size
        unit = var.resources.storage.unit
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

  # Remote address configurations
  bus_remote_addr = var.worker_config.bus_remote_addr != null ? "${local.proto}://${var.worker_config.bus_remote_addr}/api/bus" : ""

  autopilot_bus_remote_addr = var.autopilot_config.bus_remote_addr != null ? "${local.proto}://${var.autopilot_config.bus_remote_addr}/api/bus" : ""

  # Worker configurations
  worker_download_config = {
    max_memory = try(var.worker_config.download.max_memory, "1Gi")
    max_overdrive = try(var.worker_config.download.max_overdrive, 5)
    overdrive_timeout = try(var.worker_config.download.overdrive_timeout, "3s")
  }

  worker_upload_config = {
    max_memory = try(var.worker_config.upload.max_memory, "1Gi")
    max_overdrive = try(var.worker_config.upload.max_overdrive, 5)
    overdrive_timeout = try(var.worker_config.upload.overdrive_timeout, "3s")
  }

  # Database environment variables
  database_env_vars = var.database != null ? {
    RENTERD_DB_URI          = var.database.uri
    RENTERD_DB_USER         = var.database.user
    RENTERD_DB_PASSWORD     = var.database.password
    RENTERD_DB_NAME         = var.database.database
    RENTERD_DB_METRICS_NAME = var.database.metrics_database
    RENTERD_DB_SSL_MODE     = var.database.ssl_mode
  } : {}

  # Base environment variables for bus mode
  bus_base_env_vars = {
    RENTERD_AUTOPILOT_ENABLED = "false"
    RENTERD_WORKER_ENABLED    = "false"
    RENTERD_SEED              = var.seed
    RENTERD_HTTP_ADDRESS      = ":${local.http_port}"
    # Using internal S3 port to avoid port conflicts
    RENTERD_S3_ADDRESS        = ":${local.s3_internal_port}"

    # Bus-specific configurations
    RENTERD_BUS_BOOTSTRAP = tostring(coalesce(var.bus_config.bootstrap, true))
    RENTERD_BUS_PERSIST_INTERVAL = coalesce(var.bus_config.persist_interval, "1m")
    RENTERD_API_PASSWORD         = var.api_password

    # Metrics configuration
    METRICS_PASSWORD         = var.metrics_password
  }

  # Base environment variables for worker mode
  worker_base_env_vars = {
    RENTERD_API_PASSWORD = var.api_password
    RENTERD_SEED         = var.seed
    RENTERD_HTTP_ADDRESS = ":${local.http_port}"

    RENTERD_BUS_REMOTE_ADDR      = local.bus_remote_addr
    RENTERD_BUS_API_PASSWORD = var.worker_config.bus_remote_password
    RENTERD_WORKER_EXTERNAL_ADDR = local.worker_external_addr
    RENTERD_WORKER_ID = coalesce(var.worker_config.id, "worker")

    # Download configurations
    RENTERD_WORKER_DOWNLOAD_MAX_MEMORY = local.worker_download_config.max_memory
    RENTERD_WORKER_DOWNLOAD_MAX_OVERDRIVE = tostring(local.worker_download_config.max_overdrive)
    RENTERD_WORKER_DOWNLOAD_OVERDRIVE_TIMEOUT = local.worker_download_config.overdrive_timeout

    # Upload configurations
    RENTERD_WORKER_UPLOAD_MAX_MEMORY        = local.worker_upload_config.max_memory
    RENTERD_WORKER_UPLOAD_MAX_OVERDRIVE = tostring(local.worker_upload_config.max_overdrive)
    RENTERD_WORKER_UPLOAD_OVERDRIVE_TIMEOUT = local.worker_upload_config.overdrive_timeout

    RENTERD_AUTOPILOT_ENABLED = "false"

    # Metrics configuration
    METRICS_PASSWORD         = var.metrics_password
  }

  # Base environment variables for autopilot mode
  autopilot_base_env_vars = {
    RENTERD_HTTP_ADDRESS = ":${local.http_port}"
    RENTERD_WORKER_ENABLED = "false"

    # Autopilot-specific configurations
    RENTERD_BUS_REMOTE_ADDR  = local.autopilot_bus_remote_addr
    RENTERD_BUS_API_PASSWORD = var.autopilot_config.bus_remote_password

    RENTERD_WORKER_API_PASSWORD = var.autopilot_config.worker_api_password
    RENTERD_WORKER_REMOTE_ADDRS = join(";", [
      for addr in coalesce(var.autopilot_config.worker_remote_addrs, []) :
      "${local.proto}://${addr}/api/worker"
    ])

    # Disable bus and worker
    RENTERD_WORKER_ENABLED = "false"
    RENTERD_AUTOPILOT_ENABLED = "true"

    RENTERD_API_PASSWORD = var.api_password

    # Metrics configuration
    METRICS_PASSWORD         = var.metrics_password
  }

  # Main base environment variables
  base_env_vars = local.is_cluster_mode ? (
    var.mode == "bus" ? local.bus_base_env_vars :
      var.mode == "worker" ? local.worker_base_env_vars :
        var.mode == "autopilot" ? local.autopilot_base_env_vars :
        {}
  ) : {
    # Non-cluster mode configuration
    RENTERD_SEED         = var.seed
    RENTERD_HTTP_ADDRESS = ":${local.http_port}"
    # Using internal S3 port to avoid port conflicts
    RENTERD_S3_ADDRESS   = ":${local.s3_internal_port}"
    RENTERD_API_PASSWORD = var.api_password

    # Enable all components by default in non-cluster mode
    RENTERD_WORKER_ENABLED    = "true"
    RENTERD_AUTOPILOT_ENABLED = "true"

    # Metrics configuration
    METRICS_PASSWORD         = var.metrics_password
  }

  # 3. Environment variables - Final merged configuration
  service_env_vars = merge(
    local.base_env_vars,
    local.database_env_vars
  )

  # Service expose configuration with port mapping
  # Maps internal S3 port to external port while maintaining external port 80 when specified
  service_expose = concat(
    [
      {
        port   = local.http_port
        as     = local.http_port
        global = true
        proto  = "tcp"
        accept = local.service_fqdn != null ? [local.service_fqdn] : []
      }
    ],
      var.network.s3_enabled ? [
      {
        port   = local.s3_internal_port  # Internal port (9981 when external is 80)
        as     = local.s3_port          # External port (remains 80 when specified)
        global = true
        proto  = "tcp"
        accept = local.s3_fqdn != null ? [local.s3_fqdn] : []
      }
    ] : []
  )

  # Service configuration
  service_config = {
    name = local.base_config.name
    image = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory = local.base_config.memory
    storage = local.storage_config
    env = local.service_env_vars
    expose = local.service_expose
  }
}
