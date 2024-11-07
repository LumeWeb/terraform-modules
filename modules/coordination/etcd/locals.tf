locals {
  # Service configuration
  service_config = {
    name      = var.name
    image     = "ghcr.io/lumeweb/akash-etcd:develop"
    cpu_units = var.cpu_cores
    memory = {
      value = var.memory_size
      unit  = var.memory_unit
    }
    storage = {
      root = {
        size = {
          value = var.storage_size
          unit  = var.storage_unit
        }
      }
      persistent_data = {
        size = {
          value = var.persistent_storage_size
          unit  = var.persistent_storage_unit
        }
        mount = "/bitnami/etcd"
        class = var.persistent_storage_class
      }
    }
    env = {
      ALLOW_NONE_AUTHENTICATION  = "no"
      ETCD_ROOT_PASSWORD         = var.root_password
      ETCD_NAME                  = "etcd"
    }
    expose = [
      {
        port   = 2379
        proto  = "tcp"
        global = true
      }
    ]
  }
}
