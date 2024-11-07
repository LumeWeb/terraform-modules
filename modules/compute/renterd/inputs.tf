variable "network" {
  description = "Network configuration"
  type = object({
    http_port     = optional(number, 9980)
    gateway_port  = optional(number, 9981)
    s3_port       = optional(number, 9982)
    base_url      = optional(string, "http://localhost")
    enable_ssl    = optional(bool, true)
  })
  default = {}
}

variable "database" {
  description = "Database configuration"
  type = object({
    type = optional(string, "sqlite")

    # SQLite specific
    sqlite_path = optional(string, "/data/db/renterd.sqlite")
    sqlite_metrics_path = optional(string, "db/db/renterd_metrics.sqlite")

    # MySQL specific
    mysql_uri      = optional(string)
    mysql_user     = optional(string, "renterd")
    mysql_password = optional(string)
    mysql_database = optional(string, "renterd")
    mysql_metrics_database = optional(string, "renterd_metrics")
  })
  default = {}

  # Validation rules
  validation {
    condition = var.database.type == "sqlite" || var.database.type == "mysql"
    error_message = "Database type must be either 'sqlite' or 'mysql'."
  }

  # SQLite-specific validations
  validation {
    condition = var.database.type != "sqlite" || (
    var.database.sqlite_path != null &&
    var.database.sqlite_metrics_path != null
    )
    error_message = "When using SQLite, both sqlite_path and sqlite_metrics_path must be specified."
  }

  # MySQL-specific validations
  validation {
    condition = var.database.type != "mysql" || (
    var.database.mysql_uri != null &&
    var.database.mysql_user != null &&
    var.database.mysql_password != null &&
    var.database.mysql_database != null &&
    var.database.mysql_metrics_database != null
    )
    error_message = "When using MySQL, all MySQL-specific configuration parameters must be specified."
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
}

variable "metrics_password" {
  description = "Password for the metrics service"
    type = string
    sensitive = true
}