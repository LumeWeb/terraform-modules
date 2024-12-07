check "bus_mode_config" {
  assert {
    condition = !var.cluster || var.mode != "bus" || (
      length(keys(var.bus_config)) > 0 && 
      try(var.bus_config.persist_interval != null, false)
    )
    error_message = "Bus mode requires bus_config with persist_interval when cluster=true"
  }
}

check "database_configuration" {
  assert {
    condition = var.database != null
    error_message = "Database configuration is required"
  }
}

check "worker_mode_config" {
  assert {
    condition = !var.cluster || var.mode != "worker" || (
      length(keys(var.worker_config)) > 0 && 
      try(var.worker_config.bus_remote_addr != null, false) &&
      try(var.worker_config.bus_remote_password != null, false) &&
      try(var.worker_config.id != null, false)
    )
    error_message = "Worker mode requires worker_config with bus_remote_addr, bus_remote_password and id when cluster=true"
  }
}

check "autopilot_mode_config" {
  assert {
    condition = !var.cluster || var.mode != "autopilot" || (
      length(keys(var.autopilot_config)) > 0 &&
      try(var.autopilot_config.bus_remote_addr != null, false) &&
      try(var.autopilot_config.bus_remote_password != null, false)
    )
    error_message = "Autopilot mode requires autopilot_config with bus_remote_addr and bus_remote_password when cluster=true"
  }
}
