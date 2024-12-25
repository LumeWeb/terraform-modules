locals {
  base_config = {
    name = var.name
    image = var.image
    cpu_units = var.cpu_units
    memory = {
      value = var.memory_size
      unit = var.memory_unit
    }
  }

  storage_config = {
    root = {
      size = {
        value = var.storage_size
        unit = var.storage_unit
      }
    }
    persistent_data = try(var.persistent_storage, null) != null ? {
      size = {
        value = var.persistent_storage.size
        unit = var.persistent_storage.unit
      }
      class = var.persistent_storage.class
    } : null
  }

  base_env_vars = {
    PROMETHEUS_ADMIN_USERNAME = var.prometheus_admin_username
    PROMETHEUS_ADMIN_PASSWORD = var.prometheus_admin_password
    PROMETHEUS_CONFIG_FILE = var.prometheus_config_file
    PROMETHEUS_DATA_DIR = var.prometheus_data_dir
    AWS_ACCESS_KEY_ID = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    AWS_REGION = var.aws_region
    AWS_BUCKET_NAME = var.s3_bucket
    AWS_S3_ENDPOINT = var.s3_endpoint
    BACKUP_SCHEDULE = var.backup_schedule
    RETENTION_DAYS = var.retention_days
    MAX_DISK_USAGE_PERCENT = var.max_disk_usage_percent
    PROMSTER_LOG_LEVEL = var.promster_log_level
    PROMSTER_SCRAPE_ETCD_URL = var.promster_scrape_etcd_url
    PROMSTER_ETCD_BASE_PATH = var.promster_etcd_base_path
    PROMSTER_ETCD_USERNAME = var.promster_etcd_username
    PROMSTER_ETCD_PASSWORD = var.promster_etcd_password
    PROMSTER_ETCD_TIMEOUT = var.promster_etcd_timeout
    PROMSTER_SCRAPE_ETCD_PATHS = join(",", var.promster_scrape_etcd_paths)
    PROMSTER_SCRAPE_INTERVAL = var.promster_scrape_interval
    PROMSTER_SCRAPE_TIMEOUT = var.promster_scrape_timeout
    PROMSTER_EVALUATION_INTERVAL = var.promster_evaluation_interval
    PROMSTER_SCHEME = var.promster_scheme
    PROMSTER_TLS_INSECURE = var.promster_tls_insecure
  }

  service_expose = [
    {
      port = 9090
      protocol = "TCP"
      global = true
    }
  ]

  service_config = {
    name = local.base_config.name
    image = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory = local.base_config.memory
    storage = local.storage_config
    env = local.base_env_vars
    expose = local.service_expose
  }
}

module "prometheus_deployment" {
  source = "../../compute/akash"

  service = local.service_config

  placement_strategy = {
    name = "${var.name}-placement"
    attributes = var.placement_attributes
    pricing = {
      denom = "uakt"
      amount = var.pricing_amount
    }
  }

  allowed_providers = var.allowed_providers
  environment = var.environment
  tags = var.tags
}
