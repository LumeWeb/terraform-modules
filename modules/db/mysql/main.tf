module "mysql_deployment" {
  source = "../../compute/akash"

  service = {
    name      = local.base_config.name
    image     = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory    = local.base_config.memory
    storage   = local.storage_config
    env       = local.service_env_vars
    expose    = local.service_expose
  }

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
