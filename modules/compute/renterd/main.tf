
check "cluster_mode_configuration" {
  assert {
    condition = !var.cluster || (
      var.mode == "bus" ? (
        length(keys(var.bus_config)) > 0 && 
        try(var.bus_config.persist_interval != null, false)
      ) : var.mode == "worker" ? (
        length(keys(var.worker_config)) > 0 && 
        try(var.worker_config.bus_remote_addr != null, false) &&
        try(var.worker_config.bus_remote_password != null, false) &&
        try(var.worker_config.id != null, false)
      ) : var.mode == "autopilot" ? (
        length(keys(var.autopilot_config)) > 0 &&
        try(var.autopilot_config.bus_remote_addr != null, false) &&
        try(var.autopilot_config.bus_remote_password != null, false)
      ) : false
    )
    error_message = "Invalid cluster mode configuration. When cluster=true:\n" +
      "- For bus mode: bus_config with persist_interval is required\n" +
      "- For worker mode: worker_config with bus_remote_addr, bus_remote_password and id is required\n" +
      "- For autopilot mode: autopilot_config with bus_remote_addr and bus_remote_password is required"
  }
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
