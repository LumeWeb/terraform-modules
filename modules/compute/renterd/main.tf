
# Validate cluster mode configuration
locals {
  validate_cluster_mode = var.cluster ? (
    var.mode == "bus" ? (
      var.bus_config != {} && var.bus_config.persist_interval != null ? null : 
      file("ERROR: When running in cluster mode as bus node, bus_config with persist_interval must be provided")
    ) : var.mode == "worker" ? (
      var.worker_config != {} && var.worker_config.bus_remote_addr != null && 
      var.worker_config.bus_remote_password != null && var.worker_config.id != null ? null :
      file("ERROR: When running in cluster mode as worker node, worker_config with required fields must be provided")
    ) : var.mode == "autopilot" ? (
      var.autopilot_config != {} && var.autopilot_config.bus_remote_addr != null &&
      var.autopilot_config.bus_remote_password != null ? null :
      file("ERROR: When running in cluster mode as autopilot node, autopilot_config with required fields must be provided")
    ) : file("ERROR: When cluster mode is enabled, mode must be one of: bus, worker, autopilot")
  ) : null
}

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
