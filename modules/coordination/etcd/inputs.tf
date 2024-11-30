variable "name" {
  description = "Name for the etcd service"
  type        = string
  default     = "etcd"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens"
  }
}

variable "image" {
  description = "ETCD container image"
  type        = string
  default     = "ghcr.io/lumeweb/akash-etcd:develop"
}

variable "root_password" {
  description = "Root password for etcd authentication"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.root_password) >= 8
    error_message = "Root password must be at least 8 characters long"
  }
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
      mount = optional(string, "/bitnami/etcd")
    }), {})
  })
  default = {}
}

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
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
