check "cluster_bus_config" {
  assert {
    condition = !var.cluster || var.mode != "bus" || var.bus_config != {}
    error_message = "When running in cluster mode as bus node, bus_config must be provided."
  }
}

check "cluster_worker_config" {
  assert {
    condition = !var.cluster || var.mode != "worker" || var.worker_config != {}
    error_message = "When running in cluster mode as worker node, worker_config must be provided."
  }
}

check "cluster_autopilot_config" {
  assert {
    condition = !var.cluster || var.mode != "autopilot" || var.autopilot_config != {}
    error_message = "When running in cluster mode as autopilot node, autopilot_config must be provided."
  }
}