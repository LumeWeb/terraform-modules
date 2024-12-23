variable "admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 8
    error_message = "Admin password must be at least 8 characters long."
  }
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_image" {
  description = "Grafana container image"
  type        = string
  default     = "grafana/grafana:10.2.2"
}

variable "grafana_port" {
  description = "Grafana web interface port"
  type        = number
  default     = 3000
}

variable "plugins" {
  description = "List of Grafana plugins to install"
  type        = list(string)
  default     = []
}

variable "dns" {
  description = "DNS configuration for Grafana"
  type = object({
    domain      = string
    enable_tls  = optional(bool, true)
  })

  validation {
    condition     = can(regex("^([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,}$", var.dns.domain))
    error_message = "Domain must be a valid domain name (e.g., grafana.example.com)."
  }
}

# Resource Configuration
variable "cpu_units" {
  description = "CPU units for Grafana service"
  type        = number
  default     = 1000
}

variable "memory_size" {
  description = "Memory size for Grafana service"
  type        = number
  default     = 1
}

variable "memory_unit" {
  description = "Memory unit (Gi, Mi)"
  type        = string
  default     = "Gi"
}

variable "storage_size" {
  description = "Storage size for Grafana data"
  type        = number
  default     = 10
}

variable "storage_unit" {
  description = "Storage unit (Gi, Mi)"
  type        = string
  default     = "Gi"
}

# Akash Placement Configuration
variable "placement_strategy_name" {
  description = "Name of the placement strategy"
  type        = string
  default     = "grafana-placement"
}

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
}

# Tags
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# Database Configuration
variable "database" {
  description = "Database configuration"
  type = object({
    host     = string
    port     = number
    username = string
    password = string
    name     = optional(string, "grafana")
    type     = optional(string, "sqlite")
    ssl_mode      = optional(string)
  })
  sensitive = true
}