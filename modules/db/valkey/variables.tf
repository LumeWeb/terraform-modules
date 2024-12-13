variable "name" {
  description = "Name for the Valkey service"
  type        = string
  default     = "valkey"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens"
  }
}

variable "image" {
  description = "Valkey container image"
  type        = string
  default     = "ghcr.io/lumeweb/akash-valkey:develop"
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
    persistent_storage = optional(object({
      size = optional(number, 1)
      unit = optional(string, "Gi")
      class = optional(string, "beta3")
      mount = optional(string, "/data")
    }), {})
  })
  default = {}
}

variable "valkey_config" {
  description = "Valkey specific configuration"
  type = object({
    port             = optional(number, 6379)
    bind             = optional(string, "0.0.0.0")
    maxmemory        = optional(number, 0)
    maxmemory_policy = optional(string, "noeviction")
    appendonly       = optional(bool, false)
    requirepass      = optional(string, "")
  })
  default = {}

  validation {
    condition     = var.valkey_config.port >= 1 && var.valkey_config.port <= 65535
    error_message = "Port must be between 1 and 65535"
  }
}

variable "backup_config" {
  description = "Backup configuration for Valkey"
  type = object({
    enabled         = optional(bool, false)
    schedule        = optional(string, "0 0 * * *")
    s3_endpoint     = optional(string)
    s3_access_key   = optional(string)
    s3_secret_key   = optional(string)
    s3_bucket       = optional(string)
  })
  default = {}
}

# Common variables as per guidelines
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type        = map(string)
  default     = {}
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
} 