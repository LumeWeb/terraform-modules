variable "name" {
  description = "Name for the renterd deployment"
  type        = string
  default     = "renterd"
}

variable "network" {
  description = "Network configuration"
  type = object({
    http_port     = optional(number, 9980)
    s3_port       = optional(number, 9982)
    s3_enabled    = optional(bool, true)
    enable_ssl    = optional(bool, true)
  })
  default = {}

  validation {
    condition = alltrue([
      var.network.http_port >= 80 && var.network.http_port <= 65535,
      var.network.s3_port >= 80 && var.network.s3_port <= 65535
    ])
    error_message = "All ports must be between 80 and 65535"
  }
}

variable "dns" {
  description = "DNS configuration"
  type = object({
    base_domain = string
    bus_prefix = optional(string, "bus")
    worker_prefix = optional(string, "worker")
    autopilot_prefix = optional(string, "autopilot")
    solo_prefix = optional(string, "solo")
    worker_id = optional(string, "1")
  })
}

variable "database" {
  description = "Database configuration"
  type = object({
    type = optional(string, "mysql")
    uri = optional(string)
    user = optional(string, "root") 
    password = optional(string)
    database = optional(string, "renterd")
    metrics_database = optional(string, "renterd_metrics")
    ssl_mode = optional(string, "disable")
  })
  default = null

  validation {
    condition = var.database == null ? true : alltrue([
      var.database.uri != null,
      var.database.password != null,
      var.database.database != null,
      var.database.metrics_database != null
    ])
    error_message = "When database configuration is provided, all required parameters must be set"
  }

  validation {
    condition = var.database == null ? true : contains(["disable", "prefer", "require", "verify-ca", "verify-full"], var.database.ssl_mode)
    error_message = "SSL mode must be one of: disable, prefer, require, verify-ca, verify-full"
  }
}

variable "bus_config" {
  description = "Bus node specific configuration"
  type = object({
    remote_addr     = optional(string)
    remote_password = optional(string)
    bootstrap       = optional(bool, true)
    persist_interval = optional(string, "1m")
  })
  default = {}

  validation {
    condition = var.bus_config == {} || var.bus_config.persist_interval != null
    error_message = "When bus_config is provided, persist_interval must be specified"
  }
}

variable "worker_config" {
  description = "Worker node specific configuration"
  type = object({
    bus_remote_addr     = optional(string)
    bus_remote_password = optional(string)
    external_addr       = optional(string)
    id                  = optional(string, "worker")

    download = optional(object({
      max_memory       = optional(string, "1GiB")
      max_overdrive    = optional(number, 5)
      overdrive_timeout = optional(string, "3s")
    }), {})

    upload = optional(object({
      max_memory       = optional(string, "1GiB")
      max_overdrive    = optional(number, 5)
      overdrive_timeout = optional(string, "3s")
    }), {})
  })
  default = {}

}

variable "autopilot_config" {
  description = "Autopilot node specific configuration"
  type = object({
    bus_remote_addr     = optional(string)
    bus_remote_password = optional(string)

    worker_remote_addrs  = optional(list(string), [])
    worker_api_password  = optional(string)

    contracts = optional(object({
      amount        = optional(number, 50)
      allowance     = optional(string, "10000000000000000000000000000")
      period        = optional(number, 6048)
      renew_window  = optional(number, 2016)
    }), {})

    hosts = optional(object({
      allow_redundant_ips = optional(bool, false)
      max_downtime_hours  = optional(number, 1440)
    }), {})
  })
  default = {}

}

variable "resources" {
  description = "Compute resources"
  type = object({
    cpu = optional(object({
      cores = optional(number, 2)
    }), {})
    memory = optional(object({
      size = optional(number, 4)
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

  validation {
    condition = alltrue([
      var.resources.cpu.cores > 0,
      var.resources.memory.size > 0,
      var.resources.storage.size > 0,
      var.resources.persistent_storage.size > 0
    ])
    error_message = "All resource values must be greater than 0"
  }

  validation {
    condition = alltrue([
      contains(["Ki", "Mi", "Gi", "Ti"], var.resources.memory.unit),
      contains(["Ki", "Mi", "Gi", "Ti"], var.resources.storage.unit),
      contains(["Ki", "Mi", "Gi", "Ti"], var.resources.persistent_storage.unit)
    ])
    error_message = "Resource units must be one of: Ki, Mi, Gi, Ti"
  }

  validation {
    condition = contains(["beta1", "beta2", "beta3"], var.resources.persistent_storage.class)
    error_message = "Storage class must be one of: beta1, beta2, beta3"
  }
}

variable "metrics_password" {
  description = "Password for the metrics service"
  type        = string
  sensitive   = true
}

variable "cluster" {
  description = "Enable cluster mode"
  type        = bool
  default     = false
}

variable "mode" {
  description = "Operation mode (bus, worker, autopilot)"
  type        = string
  default     = "solo"
  
  validation {
    condition     = contains(["solo", "bus", "worker", "autopilot"], var.mode)
    error_message = "Mode must be one of: solo, bus, worker, autopilot"
  }
}

variable "seed" {
  description = "Seed for the renterd instance"
  type        = string
  sensitive   = true
}

variable "api_password" {
  description = "API password for the renterd instance"
  type        = string
  sensitive   = true
}

variable "image" {
  description = "Docker image for renterd"
  type        = string
  default     = "ghcr.io/lumeweb/akash-renterd:develop"
}

variable "tags" {
  description = "Additional tags for the deployment"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "placement_attributes" {
  description = "Placement attributes for the deployment"
  type        = map(string)
  default     = {}
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)
}
