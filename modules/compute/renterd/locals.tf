locals {
  # Determine if we should apply cluster-specific configurations
  is_cluster_mode = var.cluster == true

  proto = var.network.enable_ssl ? "https" : "http"
  http_port = var.network.enable_ssl ? 80 : var.network.http_port

  # Determine the worker external address only if we are in worker mode
  worker_external_addr = var.mode == "worker" ? (
    local.service_fqdn != null ?
    "${local.proto}://${local.service_fqdn}/api/worker" :
      var.worker_config.external_addr != null && var.worker_config.external_addr != "" ?
      "${local.proto}://${var.worker_config.external_addr}/api/worker" :
      ""
  ) : ""

  # Safely extract bus remote address
  bus_remote_addr = (
  var.worker_config.bus_remote_addr != null &&
  var.worker_config.bus_remote_addr != ""
  ) ? "${local.proto}://${var.worker_config.bus_remote_addr}/api/bus" : ""

  autopilot_bus_remote_addr = (
  var.autopilot_config.bus_remote_addr != null &&
  var.autopilot_config.bus_remote_addr != ""
  ) ? "${local.proto}://${var.autopilot_config.bus_remote_addr}/api/bus" : ""


  # Default download configuration
  worker_download_config = {
    max_memory = try(var.worker_config.download.max_memory, "1Gi")
    max_overdrive = try(var.worker_config.download.max_overdrive, 5)
    overdrive_timeout = try(var.worker_config.download.overdrive_timeout, "3s")
  }

  # Default upload configuration
  worker_upload_config = {
    max_memory = try(var.worker_config.upload.max_memory, "1Gi")
    max_overdrive = try(var.worker_config.upload.max_overdrive, 5)
    overdrive_timeout = try(var.worker_config.upload.overdrive_timeout, "3s")
  }

  # Database environment variables
  database_env_vars = var.database.type == "sqlite" ? {
    RENTERD_DB_PATH         = var.database.sqlite_path
    RENTERD_DB_METRICS_PATH = var.database.sqlite_metrics_path
  } : {
    RENTERD_DB_URI          = var.database.mysql_uri
    RENTERD_DB_USER         = var.database.mysql_user
    RENTERD_DB_PASSWORD     = var.database.mysql_password
    RENTERD_DB_NAME         = var.database.mysql_database
    RENTERD_DB_METRICS_NAME = var.database.mysql_metrics_database
  }

  # Base environment variables for bus mode
  bus_base_env_vars = {
    RENTERD_AUTOPILOT_ENABLED = "false"
    RENTERD_WORKER_ENABLED    = "false"
    RENTERD_SEED              = var.seed
    RENTERD_HTTP_ADDRESS      = ":${local.http_port}"
    RENTERD_BUS_GATEWAY_ADDR = ":${var.network.gateway_port}"

    # Bus-specific configurations
    RENTERD_BUS_BOOTSTRAP = tostring(var.bus_config.bootstrap)
    RENTERD_BUS_PERSIST_INTERVAL = var.bus_config.persist_interval
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
    RENTERD_WORKER_ID = var.worker_config.id

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
      for addr in var.autopilot_config.worker_remote_addrs :
      "${local.proto}://${addr}/api/worker"
    ])

    # Disable bus and worker
    RENTERD_WORKER_ENABLED = "false"
    RENTERD_AUTOPILOT_ENABLED = "true"

    # Add environment as an environment variable
    RENTERD_ENVIRONMENT = var.environment

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
    RENTERD_API_PASSWORD = var.api_password

    # Enable all components by default in non-cluster mode
    RENTERD_WORKER_ENABLED    = "true"
    RENTERD_AUTOPILOT_ENABLED = "true"

    # Metrics configuration
    METRICS_PASSWORD         = var.metrics_password
  }

  # Merge all environment variables
  merged_env_vars = merge(
    local.base_env_vars,
    local.database_env_vars
  )

  # Determine the service FQDN based on cluster mode and node type
  service_fqdn = var.cluster ? (
    var.mode == "bus" ? "${var.dns.bus_prefix}.${var.dns.base_domain}" :
      var.mode == "worker" ? "${var.dns.worker_prefix}.${var.dns.base_domain}" :
        var.mode == "autopilot" ? "${var.dns.autopilot_prefix}.${var.dns.base_domain}" :
        null
  ) : "${var.dns.solo_prefix}.${var.dns.base_domain}"

  # Determine expose configuration dynamically with SSL toggle
  service_expose = [
    {
      port   = local.http_port
      as     = local.http_port
      global = true
      proto  = var.network.enable_ssl ? "http" : "tcp"
      accept = local.service_fqdn != null ? [local.service_fqdn] : []
    }
  ]

  # Service configuration
  service_config = {
    name = local.is_cluster_mode ? (
      var.mode == "bus" ? "renterd-bus" :
        var.mode == "worker" ? "renterd-worker" :
          var.mode == "autopilot" ? "renterd-autopilot" :
          "renterd"
    ) : "renterd-solo"
    image     = var.image
    cpu_units = var.resources.cpu.cores
    memory = {
      value = var.resources.memory.size
      unit  = var.resources.memory.unit
    }
    storage = {
      root = {
        size = {
          value = var.resources.storage.size
          unit  = var.resources.storage.unit
        }
      }
      persistent_data = {
        size = {
          value = var.resources.persistent_storage.size,
          unit  = var.resources.persistent_storage.unit
        }
        mount = var.resources.persistent_storage.mount
        class      = var.resources.persistent_storage.class
      }
    }
    env    = local.merged_env_vars
    expose = local.service_expose
  }
}
