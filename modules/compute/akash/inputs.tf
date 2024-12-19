variable "service" {
  description = "Single service deployment configuration"
  type = object({
    name      = string
    image     = string
    count     = optional(number, 1)
    cpu_units = optional(number, 2)
    memory    = object({
      value = number
      unit  = string
    })
    storage = optional(object({
      root = optional(object({
        size = object({
          value = optional(number, 1)
          unit  = optional(string, "Gi")
        })
      }), {
        size = {
          value = 1
          unit = "Gi"
        }
      })
      persistent_data = optional(object({
        size = object({
          value = number
          unit  = string
        })
        mount = optional(string, "/data")
        class = optional(string, "beta3")
        read_only = optional(bool, false)
      }))
    }), {
      root = {
        size = {
          value = 1
          unit = "Gi"
        }
      }
    })
    env       = optional(map(string), {})
    expose    = optional(list(object({
      port     = number
      as       = optional(number)
      proto    = optional(string, "tcp")
      global   = optional(bool, false)
      accept   = optional(list(string))
      to       = optional(list(object({
        global = optional(bool, false)
        ip     = optional(string)
      })))
    })), [])
  })

  validation {
    condition = can(regex("^[a-z][a-z0-9-]*$", var.service.name))
    error_message = "Service name must be lowercase alphanumeric with hyphens"
  }

  validation {
    condition = coalesce(var.service.cpu_units, 2) >= 1 && coalesce(var.service.cpu_units, 2) <= 32
    error_message = "CPU units must be between 1 and 32"
  }

  validation {
    condition = coalesce(var.service.count, 1) >= 1 && coalesce(var.service.count, 1) <= 20
    error_message = "Service count must be between 1 and 20"
  }

  validation {
    condition = alltrue([
      for port in coalesce(var.service.expose, []) :
      contains(["tcp", "udp", "http", "https"], lower(coalesce(port.proto, "tcp")))
    ])
    error_message = "Port protocol must be one of 'tcp', 'udp', 'http', or 'https'."
  }

  validation {
    condition = alltrue([
      for expose in coalesce(var.service.expose, []) :
      expose.port >= 1 && expose.port <= 65535 &&
    (expose.accept == null || length(coalesce(expose.accept, [])) > 0)
      ])
    error_message = "Invalid expose configuration. Port must be between 1-65535 and accept must be null or non-empty array"
  }

  validation {
    condition = var.service.storage.persistent_data == null || (
    can(regex("^(/[^/]+)+$", coalesce(var.service.storage.persistent_data.mount, "/data")))
    )
    error_message = "Invalid mount path format. Must be an absolute path"
  }

  validation {
    condition = var.service.storage.persistent_data == null || (
    contains(["beta1", "beta2", "beta3"], coalesce(var.service.storage.persistent_data.class, "beta3"))
    )
    error_message = "Invalid storage class. Must be one of: beta1, beta2, beta3"
  }

  validation {
    condition = contains(["Ki", "Mi", "Gi", "Ti"], var.service.memory.unit) && (
    contains(["Ki", "Mi", "Gi", "Ti"], coalesce(var.service.storage.root.size.unit, "Gi")) &&
    (var.service.storage.persistent_data == null ||
    contains(["Ki", "Mi", "Gi", "Ti"], coalesce(var.service.storage.persistent_data.size.unit, "Gi")))
    )
    error_message = "Memory and storage units must be one of: Ki, Mi, Gi, Ti"
  }
}

variable "placement_strategy" {
  description = "Placement strategy configuration"
  type = object({
    name       = string
    attributes = optional(map(string), {})
    pricing = object({
      denom  = string
      amount = number
    })
  })

  validation {
    condition = can(regex("^[a-z][a-z0-9-]*$", var.placement_strategy.name))
    error_message = "Placement strategy name must be lowercase alphanumeric with hyphens"
  }
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)

  validation {
    condition = alltrue([
      for provider in var.allowed_providers :
      can(regex("^akash[0-9a-z]{39}$", provider))
    ])
    error_message = "Invalid Akash provider address format"
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "debug" {
  description = "Enable debug output"
  type = object({
    enabled = bool
    path = optional(string, "/tmp")
  })
  default = {
    enabled = false
    path    = "/tmp"
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "ip_endpoints" {
  description = "IP endpoints configuration"
  type        = map(object({
    kind = string
  }))
  default     = {}
}
