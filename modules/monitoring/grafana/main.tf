locals {
  # Base Grafana environment variables
  base_env_vars = {
    GF_SECURITY_ADMIN_USER     = var.admin_user
    GF_SECURITY_ADMIN_PASSWORD = var.admin_password
    GF_SERVER_HTTP_PORT        = var.grafana_port
    GF_INSTALL_PLUGINS         = join(",", var.plugins)
  }

  # Grafana service configuration
  service_config = {
    grafana = {
      image = var.grafana_image
      cpu_units = var.cpu_units
      memory = {
        value = var.memory_size
        unit  = var.memory_unit
      }
      storage = [{
        mount_path = "/var/lib/grafana"
        size = {
          value = var.storage_size
          unit  = var.storage_unit
        }
        persistent = true
      }]
      env = local.base_env_vars
      expose = [{
        port   = var.grafana_port
        as     = 443
        global = true
        proto  = "http"
        accept = [var.dns.domain]
      }]
    }
  }
}

module "grafana_deployment" {
  source = "../../compute/akash"

  service = local.service_config

  placement_strategy = {
    name = var.placement_strategy_name
    attributes = var.placement_attributes
    pricing = {
      denom = "uakt"
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
