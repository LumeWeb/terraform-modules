# Core Configuration
variable "name" {
  description = "Name for the ProxySQL service"
  type        = string
  default     = "proxysql"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens"
  }
}

variable "image" {
  description = "ProxySQL container image"
  type        = string
  default     = "ghcr.io/lumeweb/akash-proxysql:develop"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

# Authentication
variable "admin_password" {
  description = "ProxySQL admin password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 8
    error_message = "Admin password must be at least 8 characters long"
  }
}

# Resource Configuration
variable "resources" {
  description = "Compute resources configuration"
  type = object({
    cpu = optional(object({
      cores = optional(number, 1)
    }), {})
    memory = optional(object({
      size = optional(number, 512)
      unit = optional(string, "Mi")
    }), {})
    storage = optional(object({
      size = optional(number, 1)
      unit = optional(string, "Gi")
    }), {})
    persistent_storage = optional(object({
      size = optional(number, 1)
      unit = optional(string, "Gi")
      class = optional(string, "beta3")
      mount = optional(string, "/var/lib/proxysql")
    }), {})
  })
  default = {}

  validation {
    condition = contains(["Ki", "Mi", "Gi", "Ti"], var.resources.memory.unit)
    error_message = "Memory unit must be one of: Ki, Mi, Gi, Ti"
  }

  validation {
    condition = var.resources.persistent_storage == null || contains(["beta1", "beta2", "beta3"], var.resources.persistent_storage.class)
    error_message = "Storage class must be one of: beta1, beta2, beta3"
  }
}

# Network Configuration
variable "ports" {
  description = "Port configuration"
  type = object({
    proxy = optional(number, 6033)
    admin = optional(number, 6032)
  })
  default = {}

  validation {
    condition = var.ports.proxy >= 1024 && var.ports.proxy <= 65535
    error_message = "Proxy port must be between 1024 and 65535"
  }

  validation {
    condition = var.ports.admin >= 1024 && var.ports.admin <= 65535
    error_message = "Admin port must be between 1024 and 65535"
  }
}

# ETCD Integration
variable "etcd" {
  description = "ETCD configuration"
  type = object({
    endpoints = optional(list(string), [])
    username = optional(string, "root")
    password = optional(string, "")
  })
  default = {}

  validation {
    condition = length(var.etcd.endpoints) == 0 || can(regex("^[a-zA-Z0-9_-]+$", var.etcd.username))
    error_message = "ETCD username must be alphanumeric with underscores and hyphens"
  }

  validation {
    condition     = length(var.etcd.endpoints) > 0 && length(var.etcd.password) > 0
    error_message = "ETCD password must not be empty when endpoints are provided"
  }
}

# Akash Configuration
variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type        = map(string)
  default     = {}
}

variable "pricing_amount" {
  description = "Maximum price for deployment in uakt"
  type        = number
  default     = 10000
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for provider in var.allowed_providers :
      can(regex("^akash[0-9a-z]{39}$", provider))
    ])
    error_message = "Invalid Akash provider address format"
  }
}

# MYSQL Configuration

variable "mysql" {
  description = "MySQL configuration"
  type = object({
    repl_user = optional(string, "repl")
    repl_password = optional(string)
  })

  validation {
    condition = var.mysql.repl_password != null
    error_message = "Replication password must be set"
  }

  validation {
    condition = can(regex("^[a-zA-Z0-9_-]+$", var.mysql.repl_user))
    error_message = "Replication username must be alphanumeric with underscores and hyphens"
  }
}


# Tags
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
