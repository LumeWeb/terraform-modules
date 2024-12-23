locals {
  # Base Grafana environment variables
  base_env_vars = {
    GF_SECURITY_ADMIN_USER     = var.admin_user
    GF_SECURITY_ADMIN_PASSWORD = var.admin_password
    GF_SERVER_HTTP_PORT        = var.grafana_port
    GF_INSTALL_PLUGINS = join(",", var.plugins)

    # Database configuration
    GF_DATABASE_TYPE     = var.database.type
    GF_DATABASE_NAME     = var.database.name
    GF_DATABASE_USER     = var.database.username
    GF_DATABASE_PASSWORD = var.database.password
    GF_DATABASE_SSL_MODE = var.database.ssl_mode
  }

  storage_config = {
    persistent_data = var.database.type == "sqlite" ? {
      size = {
        value = var.storage_size
        unit = var.storage_unit
      }
      mount = "/var/lib/grafana"
      class = "beta3"
    } : null
  }

  # Grafana service configuration
  service_config = {
    name      = var.name
    image     = var.image
    cpu_units = var.cpu_units
    memory = {
      value = var.memory_size
      unit  = var.memory_unit
    }
    storage = local.storage_config
    env     = local.base_env_vars
    expose = [
      {
        port   = var.grafana_port
        as     = 80
        global = true
        proto  = "http"
        accept = [var.dns.domain]
      }
    ]
  }
}

module "grafana_deployment" {
  source = "../../compute/akash"

  service = local.service_config

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
      Service = "Grafana"
      Role    = "monitoring"
    }
  )
}
