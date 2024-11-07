variable "dns" {
  description = "DNS configuration for Renterd services"
  type = object({
    base_domain = string

    # Optional custom subdomain prefixes
    bus_prefix      = optional(string, "bus")
    worker_prefix   = optional(string, "worker")
    autopilot_prefix = optional(string, "autopilot")
    solo_prefix     = optional(string, "renterd")

    # TLS configuration
    enable_tls      = optional(bool, true)
  })

  # Validation block
  validation {
    # Ensure base_domain is a valid domain
    condition     = can(regex("^([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,}$", var.dns.base_domain))
    error_message = "base_domain must be a valid domain name (e.g., example.com)."
  }

  validation {
    # Ensure prefixes are valid DNS subdomains
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.dns.bus_prefix))
    error_message = "bus_prefix must be a valid DNS subdomain (lowercase, alphanumeric, optional hyphens)."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.dns.worker_prefix))
    error_message = "worker_prefix must be a valid DNS subdomain (lowercase, alphanumeric, optional hyphens)."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.dns.autopilot_prefix))
    error_message = "autopilot_prefix must be a valid DNS subdomain (lowercase, alphanumeric, optional hyphens)."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.dns.solo_prefix))
    error_message = "solo_prefix must be a valid DNS subdomain (lowercase, alphanumeric, optional hyphens)."
  }

  # Ensure unique prefixes
  validation {
    condition = length(
      distinct([
        var.dns.bus_prefix,
        var.dns.worker_prefix,
        var.dns.autopilot_prefix,
        var.dns.solo_prefix
      ])
    ) == 4
    error_message = "All DNS prefixes must be unique to prevent conflicts."
  }
}

variable "cluster" {
  description = "Enable cluster mode deployment"
  type        = bool
  default     = false
}

variable "mode" {
  description = "Cluster mode deployment type (bus, worker, or autopilot). Only applies when cluster = true"
  type        = string
  default     = "bus"

  validation {
    condition     = contains(["bus", "worker", "autopilot"], var.mode)
    error_message = "Mode must be either 'bus', 'worker', or 'autopilot'."
  }
}

variable "image" {
  description = "Renterd container image"
  type        = string
  default     = "ghcr.io/siafoundation/renterd:1.0.8"
}

variable "seed" {
  description = "Wallet seed for Renterd"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)
  default     = []
}

variable "api_password" {
  description = "API password for Renterd"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.api_password) >= 8
    error_message = "API password must be at least 8 characters long."
  }
}

variable "placement_attributes" {
  description = "Placement attributes for Akash deployment"
  type        = map(string)
  default     = {}
}