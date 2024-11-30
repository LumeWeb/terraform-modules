locals {


  # Name handling constants
  k8s_max_length = 63
  k8s_hash_length = 8  # Reduced from 10

  # Hash the tags instead of using them directly
  tag_hash = length(var.tags) > 0 ? sha256(jsonencode(var.tags)) : ""
  tag_prefix = substr(local.tag_hash, 0, local.k8s_hash_length)

  # Build name with core components first
  core_name = "${var.service.name}-${var.environment}"

  # Add tag hash if tags exist
  service_name = length(var.tags) > 0 ? "${local.core_name}-${local.tag_prefix}" : local.core_name

  # Ensure final name meets length requirements
  final_service_name = length(local.service_name) > local.k8s_max_length ? substr(local.service_name, 0, local.k8s_max_length) : local.service_name

  # Create truncated name that fits within k8s limits
  debug_file = "${var.debug.path}/akash_sdl_debug_${formatdate("YYYY-MM-DD-hhmm", timestamp())}.txt"

  # Service configuration components
  service_env = length(var.service.env) > 0 ? [
    for k, v in var.service.env : "${k}=${v}"
  ] : null

  service_expose = length(var.service.expose) > 0 ? [
    for port in var.service.expose : merge(
      {
        port = port.port
        to = port.global ? [{ global = true }] : []
        as = try(coalesce(port.as, port.port), port.port)
      },
        lower(port.proto) != "http" ? { proto = port.proto } : {},
      try(length(coalesce(port.accept, [])) > 0 ? { accept = port.accept } : {}, {})
    )
  ] : null

  # Service storage configuration
  service_storage = try(var.service.storage.persistent_data, null) != null ? {
    data = {
      mount = var.service.storage.persistent_data.mount
      readOnly = var.service.storage.persistent_data.read_only
    }
  } : null

  # Compute storage configuration
  compute_storage = concat(
    [{
      size = "${var.service.storage.root.size.value}${var.service.storage.root.size.unit}"
    }],
      try(var.service.storage.persistent_data, null) != null ? [{
      name = "data"
      size = "${var.service.storage.persistent_data.size.value}${var.service.storage.persistent_data.size.unit}"
      attributes = {
        persistent = true
        class = var.service.storage.persistent_data.class
      }
    }] : []
  )

  compute_resources = {
    cpu = {
      units = coalesce(var.service.cpu_units, 1)
    }
    memory = {
      size = "${var.service.memory.value}${var.service.memory.unit}"
    }
    storage = local.compute_storage
  }

  # Placement configuration
  placement_config = merge(
      var.placement_strategy.attributes != {} ? { attributes = var.placement_strategy.attributes } : {},
    {
      pricing = {
        "${local.final_service_name}" = {
          denom  = var.placement_strategy.pricing.denom
          amount = var.placement_strategy.pricing.amount
        }
      }
    }
  )

  # Deployment configuration
  deployment_config = {
    "${var.placement_strategy.name}" = {
      profile = local.service_name
      count   = coalesce(var.service.count, 1)
    }
  }

  # Final SDL structure
  service_config = {
    image   = var.service.image
    env     = local.service_env
    expose  = local.service_expose
    params = {
      storage = local.service_storage
    }
  }

  generated_sdl = {
    version = "2.0"
    services = {
      "${local.service_name}" = local.service_config
    }
    profiles = {
      compute = {
        "${local.service_name}" = {
          resources = local.compute_resources
        }
      }
      placement = {
        "${var.placement_strategy.name}" = local.placement_config
      }
    }
    deployment = {
      "${local.service_name}" = local.deployment_config
    }
  }
}
