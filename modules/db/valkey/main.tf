module "valkey_deployment" {
  source = "../../compute/akash"

  service = local.service_config

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
