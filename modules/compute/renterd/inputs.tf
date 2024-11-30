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
    solo_prefix = optional(string, "renterd")
  })
}

variable "database" {
  description = "Database configuration"
  type = object({
    type = optional(string, "sqlite")
    
    # SQLite specific
    sqlite_path = optional(string, "/data/db/renterd.sqlite")
    sqlite_metrics_path = optional(string, "/data/db/renterd_metrics.sqlite")
    
    # MySQL specific
    mysql_uri = optional(string)
    mysql_user = optional(string, "root")
    mysql_password = optional(string)
    mysql_database = optional(string, "renterd")
    mysql_metrics_database = optional(string, "renterd_metrics")
  })
  default = {}

  validation {
    condition = contains(["sqlite", "mysql"], var.database.type)
    error_message = "Database type must be either 'sqlite' or 'mysql'"
  }

  validation {
    condition = var.database.type != "sqlite" || (
      can(regex("^(/[^/]+)+$", var.database.sqlite_path)) &&
      can(regex("^(/[^/]+)+$", var.database.sqlite_metrics_path))
    )
    error_message = "SQLite paths must be absolute paths"
  }

  validation {
    condition = var.database.type != "mysql" || (
      var.database.mysql_uri != null &&
      var.database.mysql_user != null &&
      var.database.mysql_password != null &&
      var.database.mysql_database != null &&
      var.database.mysql_metrics_database != null
    )
    error_message = "When using MySQL, all MySQL configuration parameters must be provided"
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

  validation {
    condition     = var.worker_config == {} || (
      var.worker_config.bus_remote_addr != null &&
      var.worker_config.bus_remote_password != null &&
      var.worker_config.id != null
    )
    error_message = "When worker_config is provided, bus_remote_addr, bus_remote_password and id must be specified"
  }
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

  validation {
    condition     = var.autopilot_config == {} || (
      var.autopilot_config.bus_remote_addr != null &&
      var.autopilot_config.bus_remote_password != null
    )
    error_message = "When autopilot_config is provided, bus_remote_addr and bus_remote_password must be specified"
  }
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
  default     = "ghcr.io/renterd/renterd:latest"
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
