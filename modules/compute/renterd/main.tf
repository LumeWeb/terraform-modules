

module "renterd_deployment" {
  source = "../akash"

  service = local.service_config
  
  placement_strategy = {
    name = "${local.base_config.name}-placement"
    attributes = var.placement_attributes
    pricing = {
      denom = "uakt"
      amount = 10000
    }
  }

  allowed_providers = var.allowed_providers
  environment = var.environment
  tags = local.common_tags
}
