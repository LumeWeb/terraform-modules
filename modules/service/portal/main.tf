check "s3_config" {
  assert {
    condition = !var.cluster || (
      var.caddy_s3_endpoint != "" &&
      var.caddy_s3_bucket != "" &&
      var.caddy_s3_access_key != "" &&
      var.caddy_s3_secret_key != ""
    )
    error_message = "When cluster is enabled, all Caddy S3 configuration values must be provided"
  }
}

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
  tags              = merge(
    var.tags,
    local.common_tags,
    {
      environment = var.environment
    }
  )
}
