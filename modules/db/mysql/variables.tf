# Core Configuration
variable "name" {
  description = "Name for the MySQL service"
  type        = string
  default     = "mysql"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens"
  }
}

variable "image" {
  description = "MySQL container image"
  type        = string
  default     = "ghcr.io/lumeweb/akash-mysql:develop"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

# Network Configuration
variable "network" {
  description = "Network configuration"
  type = object({
    mysql_port = optional(number, 3306)
    metrics_port = optional(number, 9104)
    enable_ssl = optional(bool, false)
  })
  default = {}

  validation {
    condition = var.network.mysql_port >= 1024 && var.network.mysql_port <= 65535
    error_message = "MySQL port must be between 1024 and 65535"
  }

  validation {
    condition = var.network.metrics_port >= 1024 && var.network.metrics_port <= 65535
    error_message = "Metrics port must be between 1024 and 65535"
  }
}

# Metrics Configuration
variable "metrics" {
  description = "Metrics configuration"
  type = object({
    enabled = optional(bool, false)
    port = optional(number, 9104)
  })
  default = {}
}

# Cluster Configuration
variable "cluster" {
  description = "Cluster configuration"
  type = object({
    enabled = optional(bool, false)
    repl_user = optional(string, "repl")
    repl_password = optional(string)
    server_id = optional(number, 1)
  })
  default = {}
}

# ETCD Configuration
variable "etcd" {
  description = "ETCD configuration"
  type = object({
    endpoints = optional(list(string), [])
    username = optional(string, "root")
    password = optional(string)
  })
  default = {}
}

# Resource Configuration
variable "resources" {
  description = "Compute resources"
  type = object({
    cpu = optional(object({
      cores = optional(number, 1)
    }), {})
    memory = optional(object({
      size = optional(number, 2)
      unit = optional(string, "Gi")
    }), {})
    storage = optional(object({
      size = optional(number, 10)
      unit = optional(string, "Gi")
    }), {})
    persistent_storage = optional(object({
      size = optional(number, 10)
      unit = optional(string, "Gi")
      class = optional(string, "beta3")
      mount = optional(string, "/var/lib/mysql")
    }), {})
  })
  default = {}

  validation {
    condition = contains(["Ki", "Mi", "Gi", "Ti"], var.resources.memory.unit)
    error_message = "Memory unit must be one of: Ki, Mi, Gi, Ti"
  }

  validation {
    condition = contains(["Ki", "Mi", "Gi", "Ti"], var.resources.storage.unit)
    error_message = "Storage unit must be one of: Ki, Mi, Gi, Ti"
  }

  validation {
    condition = contains(["beta1", "beta2", "beta3"], var.resources.persistent_storage.class)
    error_message = "Storage class must be one of: beta1, beta2, beta3"
  }
}

# Performance Configuration
variable "performance" {
  description = "Performance configuration"
  type = object({
    innodb_buffer_pool_size = optional(string, "1G")
  })
  default = {}
}

# Authentication
variable "root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.root_password) >= 8
    error_message = "Root password must be at least 8 characters long"
  }
}

# Akash Configuration
variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type = map(string)
  default = {}
}

variable "pricing_amount" {
  description = "Maximum price for deployment in uakt"
  type        = number
  default     = 10000
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type = list(string)
}

variable "tags" {
  description = "Resource tags"
  type = map(string)
  default = {}
}

variable "backups_enabled" {
  description = "Enable automatic backups"
  type        = bool
  default     = true
}