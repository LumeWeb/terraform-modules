module "renterd_bus" {
  source = "../renterd"

  name                 = "${var.name}-cluster"
  cluster              = true
  image                = var.image
  mode                 = "bus"
  environment          = var.environment
  seed                 = var.seed
  api_password         = var.bus_api_password
  metrics_enabled      = var.metrics_enabled
  metrics_password     = var.metrics_password
  database             = var.database
  metrics_service_name = "${var.metrics_service_name}-bus"
  etcd_endpoints       = var.etcd_endpoints
  etcd_username        = var.etcd_username
  etcd_password        = var.etcd_password


  allowed_providers = var.allowed_providers

  placement_attributes = var.placement_attributes

  dns = {
    base_domain = var.base_domain
  }

  network = {
    enable_ssl = var.enable_ssl
    http_port  = var.http_port
  }

  resources = {
    cpu = { cores = var.bus_cpu_cores }
    memory = {
      size = var.bus_memory_size
      unit = "Gi"
    }
    persistent_storage = {
      size  = var.bus_storage_size
      path  = "/data"
      class = "beta3"
    }
  }
}

# Deploy worker nodes
module "renterd_workers" {
  source = "../renterd"
  count  = var.worker_count
  depends_on = [module.renterd_bus]

  name                 = "${var.name}-cluster"
  cluster              = true
  image                = var.image
  mode                 = "worker"
  environment          = var.environment
  seed                 = var.seed
  api_password         = var.worker_api_password
  metrics_enabled      = var.metrics_enabled
  metrics_password     = var.metrics_password
  metrics_service_name = "${var.metrics_service_name}-worker"
  etcd_endpoints       = var.etcd_endpoints
  etcd_username        = var.etcd_username
  etcd_password        = var.etcd_password

  allowed_providers = var.allowed_providers

  placement_attributes = var.placement_attributes

  dns = {
    base_domain = var.base_domain
    worker_id   = count.index + 1
  }

  network = {
    enable_ssl = var.enable_ssl
    http_port  = var.http_port
  }

  worker_config = {
    bus_remote_addr     = "${module.renterd_bus.dns_fqdn}:${module.renterd_bus.port}"
    bus_remote_password = var.bus_api_password
    id                  = count.index + 1
    download = {
      max_memory     = "${var.worker_memory_size}Gi"
      max_concurrent = 5
    }
    upload = {
      max_memory     = "${var.worker_memory_size}Gi"
      max_concurrent = 5
    }
  }

  resources = {
    cpu = { cores = var.worker_cpu_cores }
    memory = {
      size = var.worker_memory_size
      unit = "Gi"
    }
  }
}

# Deploy autopilot node
module "renterd_autopilot" {
  source = "../renterd"
  depends_on = [module.renterd_workers]

  name                 = "${var.name}-cluster"
  cluster              = true
  image                = var.image
  mode                 = "autopilot"
  environment          = var.environment
  seed                 = var.seed
  api_password         = var.worker_api_password
  metrics_enabled      = var.metrics_enabled
  metrics_password     = var.metrics_password
  metrics_service_name = "${var.metrics_service_name}-autopilot"
  etcd_endpoints       = var.etcd_endpoints
  etcd_username        = var.etcd_username
  etcd_password        = var.etcd_password

  allowed_providers = var.allowed_providers

  placement_attributes = var.placement_attributes

  dns = {
    base_domain = var.base_domain
  }

  network = {
    enable_ssl = var.enable_ssl
    http_port  = var.http_port
  }

  database = var.database

  autopilot_config = {
    bus_remote_addr     = "${module.renterd_bus.dns_fqdn}:${module.renterd_bus.port}"
    bus_remote_password = var.bus_api_password
    worker_remote_addrs = module.renterd_workers[*].dns_fqdn
    worker_api_password = var.worker_api_password
  }

  resources = {
    cpu = { cores = var.autopilot_cpu_cores }
    memory = {
      size = var.autopilot_memory_size
      unit = "Gi"
    }
  }
}
