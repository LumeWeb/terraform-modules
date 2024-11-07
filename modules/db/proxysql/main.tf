locals {
  default_image = "ghcr.io/lumeweb/akash-proxysql:develop"

  service_config = {
    name = "proxysql"
    image = local.default_image
    cpu_units = var.cpu_cores
    memory = {
      value = var.memory_size
      unit = var.memory_unit
    }
    storage = {
      root = {
        size = {
          value = var.storage_size
          unit = var.storage_unit
        }
      }
      persistent_data = {
        size = {
          value = var.storage_size
          unit = var.storage_unit
        }
        mount = "/var/lib/proxysql"
        class = "beta3"
      }
    }
    env = {
      PROXY_ADMIN_PASSWORD = var.admin_password
      ETCDCTL_API           = "3"
      ETCDCTL_ENDPOINTS     = join(",", var.etcd_endpoints)
      ETCDCTL_USER          = "${var.etcd_username}:${var.etcd_password}"
    }
    expose = [
      {
        port = var.proxy_port
        proto = "tcp"
        global = true
      },
      {
        port = var.admin_port
        proto = "tcp"
        global = false
      }
    ]
  }

  tags = merge(
    var.tags,
    {
      Service = "proxysql"
      Role    = "proxy"
    }
  )
}

module "deployment" {
  source = "../../compute/akash"

  service = local.service_config
  allowed_providers = var.allowed_providers
  placement_strategy = {
    name = "proxysql-placement"
    pricing = {
      denom = "uakt"
      amount = 10000
    }
  }
  environment = "prod"
  tags = local.tags
}
