locals {
  # 1. Base configuration
  base_config = {
    name = var.name
    image = var.image
    cpu_units = var.resources.cpu.cores
    memory = {
      value = var.resources.memory.size
      unit = var.resources.memory.unit
    }
  }

  # 2. Storage configuration
  storage_config = {
    root = {
      size = {
        value = var.resources.storage.size
        unit = var.resources.storage.unit
      }
    }
    persistent_data = try(var.resources.persistent_storage, null) != null ? {
      size = {
        value = var.resources.persistent_storage.size
        unit = var.resources.persistent_storage.unit
      }
      mount = var.resources.persistent_storage.mount
      class = var.resources.persistent_storage.class
      read_only = false
    } : null
  }

  # 3. Environment variables
  base_env_vars = {
    ALLOW_NONE_AUTHENTICATION = "no"
    ETCD_ROOT_PASSWORD = var.root_password
    ETCD_NAME = var.name
  }

  # Component-specific env vars
  component_env_vars = {
    # Cluster configuration
    cluster = var.cluster_enabled ? {
      ETCD_INITIAL_CLUSTER_TOKEN = var.cluster_token
      ETCD_INITIAL_CLUSTER_STATE = "new"
      ETCD_CLUSTER_PEERS = join(",", var.cluster_peers)
    } : {}

    # Metrics configuration
    metrics = var.metrics_enabled ? {
      ETCD_METRICS = "basic"
      ETCD_LISTEN_METRICS_URLS = "http://0.0.0.0:2381"
    } : {}
  }

  # Merge all environment variables
  service_env_vars = merge(
    local.base_env_vars,
    local.component_env_vars.cluster,
    local.component_env_vars.metrics
  )

  # 4. Service expose configuration
  service_expose = concat(
    # Main etcd port
    [{
      port = var.ports.client
      global = true
      proto = "tcp"
    }],
    # Peer port for clustering
    var.cluster_enabled ? [{
      port = var.ports.peer
      global = true 
      proto = "tcp"
    }] : [],
    # Metrics port
    var.metrics_enabled ? [{
      port = var.ports.metrics
      global = true
      proto = "tcp" 
    }] : []
  )

  # 5. Final service configuration
  service_config = {
    name = local.base_config.name
    image = local.base_config.image
    cpu_units = local.base_config.cpu_units
    memory = local.base_config.memory
    storage = local.storage_config
    env = local.service_env_vars
    expose = local.service_expose
  }

  # 6. Standard tags
  common_tags = merge(
    var.tags,
    {
      Service = "etcd"
      Component = "coordination"
      Role = var.cluster_enabled ? "cluster-node" : "standalone"
      ManagedBy = "terraform"
      Environment = var.environment
    }
  )
}
