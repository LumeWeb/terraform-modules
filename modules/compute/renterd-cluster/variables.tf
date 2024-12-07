
variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "image" {
  description = "Docker image to deploy"
  type        = string
  default     = null
}

variable "base_domain" {
  description = "Base domain for DNS cluster"
  type        = string
}

variable "seed" {
  description = "Seed phrase for renterd cluster"
  type        = string
  sensitive   = true
}

variable "bus_api_password" {
  description = "API password for the bus node"
  type        = string
  sensitive   = true
}

variable "worker_api_password" {
  description = "API password for worker nodes"
  type        = string
  sensitive   = true
}

variable "allowed_providers" {
  description = "List of allowed Sia host provider addresses"
  type        = list(string)
  default     = []
}

variable "worker_count" {
  description = "Number of worker nodes to deploy"
  type        = number
  default     = 1
}

# Resource allocation variables
variable "bus_cpu_cores" {
  description = "Number of CPU cores for bus node"
  type        = number
  default     = 1
}

variable "bus_memory_size" {
  description = "Memory size in GB for bus node"
  type        = number
  default     = 1
}

variable "bus_storage_size" {
  description = "Storage size in GB for bus node"
  type        = number
  default     = 60
}

variable "worker_cpu_cores" {
  description = "Number of CPU cores per worker"
  type        = number
  default     = 1
}

variable "worker_memory_size" {
  description = "Memory size in GB per worker"
  type        = number
  default     = 1
}

variable "placement_attributes" {
  description = "Placement attributes for Akash deployment"
  type        = map(string)
  default     = {}
}

variable "enable_ssl" {
  description = "Enable SSL for the renterd cluster"
  type        = bool
  default     = true
}

variable "metrics_password" {
  description = "Password for metrics service"
  type        = string
  sensitive   = true
}

variable "database" {
  description = "Database configuration"
  type = object({
    type = optional(string, "mysql")
    uri = optional(string)
    user = optional(string, "root") 
    password = string
    database = optional(string, "renterd")
    metrics_database = optional(string, "renterd_metrics")
    ssl_mode = optional(string, "disable")
  })

  validation {
    condition = alltrue([
      var.database.uri != null,
      var.database.user != null,
      var.database.password != null,
      var.database.database != null,
      var.database.metrics_database != null
    ])
    error_message = "All MySQL configuration parameters must be provided"
  }

  validation {
    condition = contains(["disable", "prefer", "require", "verify-ca", "verify-full"], var.database.ssl_mode)
    error_message = "SSL mode must be one of: disable, prefer, require, verify-ca, verify-full"
  }
}

variable "http_port" {
  description = "HTTP port for the renterd cluster"
  type        = number
  default     = 80
}
