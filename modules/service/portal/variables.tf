variable "name" {
  description = "Name for the Portal service"
  type        = string
  default     = "portal"

  validation {
    condition = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens"
  }
}

variable "image" {
  description = "Portal container image"
  type        = string
  default     = "ghcr.io/lumeweb/akash-portal:base-latest"
}

variable "resources" {
  description = "Compute resources configuration"
  type = object({
    cpu = optional(object({
      cores = optional(number, 1)
    }), {})
    memory = optional(object({
      size = optional(number, 1)
      unit = optional(string, "Gi")
    }), {})
    storage = optional(object({
      size = optional(number, 1)
      unit = optional(string, "Gi")
    }), {})
  })
  default = {}
}

# Core Configuration
variable "domain" {
  description = "Portal core domain"
  type        = string
}

variable "portal_name" {
  description = "Portal name"
  type        = string
}

variable "port" {
  description = "Portal core port"
  type        = number
  default     = 80
}

# Mail Configuration
variable "mail" {
  description = "Mail server configuration"
  type = object({
    host     = string
    username = string
    password = string
    from     = string
    ssl = optional(bool, false)
  })
  sensitive = true
}

# Storage Configuration
variable "storage" {
  description = "Storage configuration"
  type = object({
    s3 = object({
      buffer_bucket = string
      endpoint      = string
      region        = string
      access_key    = string
      secret_key    = string
    })
    sia = object({
      key = string
      cluster = optional(bool, false)
      url = optional(string)
    })
  })
  sensitive = true
}

# Database Configuration
variable "database" {
  description = "Database configuration"
  type = object({
    type = string
    file = optional(string)
    host = optional(string)
    port = optional(number)
    username = optional(string)
    password = optional(string)
    name = optional(string)
  })
  sensitive = true

  validation {
    condition = contains(["sqlite", "mysql"], var.database.type)
    error_message = "Database type must be either 'sqlite' or 'mysql'"
  }
}

# Redis Configuration
variable "redis" {
  description = "Redis configuration"
  type = object({
    address = string
    password = string
  })
  sensitive = true
}

# Etcd Configuration
variable "etcd" {
  description = "Etcd configuration"
  type = object({
    endpoints = list(string)
    username = string
    password = string
  })
  sensitive = true
}

# Cluster Configuration
variable "cluster" {
  description = "Cluster configuration"
  type        = bool
  default     = false
}

# Common variables from guidelines
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type = map(string)
  default = {}
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

variable "extra_env_vars" {
  description = "Additional environment variables for portal configuration and plugins"
  type = map(string)
  default = {}
  sensitive   = true
}
