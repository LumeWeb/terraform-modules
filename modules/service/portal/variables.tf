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
    tls = optional(bool, false)
    tls_skip_verify = optional(bool, false)
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
    address  = string
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
    prefix = optional(string, "/discovery")
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

variable "ssl_email" {
  description = "Email for SSL certificate"
  type        = string
}

variable "extra_env_vars" {
  description = "Additional environment variables for portal configuration and plugins"
  type = map(string)
  default = {}
  sensitive   = true
}

variable "metrics_enabled" {
  description = "Enable metrics"
  type        = bool
  default     = false
}

variable "metrics_port" {
  description = "Port for Prometheus metrics"
  type        = number
  default     = 8080
}

variable "metrics_password" {
  description = "Password for the metrics service"
  type        = string
  sensitive   = true
}

variable "metrics_service_name" {
  description = "Name of the service"
  type        = string
}

variable "metrics_etcd_prefix" {
  description = "Prefix for etcd keys for valkey service discovery by prometheus"
  type        = string
  default     = "/discovery/prometheus"
}

variable "caddy_s3_endpoint" {
  description = "S3 endpoint for Caddy storage"
  type        = string
  default     = ""

  validation {
    condition = var.caddy_s3_endpoint == "" || can(regex("^[^\\s]+$", var.caddy_s3_endpoint))
    error_message = "Caddy S3 endpoint must be empty or a valid endpoint string"
  }
}

variable "caddy_s3_bucket" {
  description = "S3 bucket for Caddy storage"
  type        = string
  default     = ""

  validation {
    condition = var.caddy_s3_bucket == "" || can(regex("^[^\\s]+$", var.caddy_s3_bucket))
    error_message = "Caddy S3 bucket must be empty or a valid bucket name"
  }
}

variable "caddy_s3_access_key" {
  description = "S3 access key for Caddy storage"
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition = var.caddy_s3_access_key == "" || can(regex("^[^\\s]+$", var.caddy_s3_access_key))
    error_message = "Caddy S3 access key must be empty or a valid key string"
  }
}

variable "caddy_s3_secret_key" {
  description = "S3 secret key for Caddy storage"
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition = var.caddy_s3_secret_key == "" || can(regex("^[^\\s]+$", var.caddy_s3_secret_key))
    error_message = "Caddy S3 secret key must be empty or a valid key string"
  }
}
