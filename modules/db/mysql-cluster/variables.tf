variable "cluster_name" {
  description = "Name of the MySQL cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.cluster_name))
    error_message = "Cluster name must be lowercase alphanumeric with hyphens"
  }
}

variable "replica_count" {
  description = "Number of replica instances to deploy"
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 0 && var.replica_count <= 10
    error_message = "replica_count must be between 0 and 10"
  }
}

variable "mysql_port" {
  description = "MySQL service port"
  type        = number
  default     = 3306
}

variable "mysql_image" {
  description = "Custom MySQL/Percona image to use"
  type        = string
  default     = null
}

variable "root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "repl_user" {
  description = "Replication user name"
  type        = string
  default     = "repl"
}

variable "repl_password" {
  description = "Password for the replication user"
  type        = string
  sensitive   = true
}

variable "master_resources" {
  description = "Resource configuration for master instance"
  type = object({
    cpu_units    = optional(number)
    memory_size  = optional(number)
    memory_unit  = optional(string)
    storage_size = optional(number)
    storage_unit = optional(string)
  })
  default = {}
}

variable "replica_resources" {
  description = "Resource configuration for replica instances"
  type = object({
    cpu_units    = optional(number)
    memory_size  = optional(number)
    memory_unit  = optional(string)
    storage_size = optional(number)
    storage_unit = optional(string)
  })
  default = {}
}

variable "default_resources" {
  description = "Default resource configuration for all instances"
  type = object({
    cpu_units    = number
    memory_size  = number
    memory_unit  = string
    storage_size = number
    storage_unit = string
  })
  default = {
    cpu_units    = 1
    memory_size  = 2
    memory_unit  = "Gi"
    storage_size = 10
    storage_unit = "Gi"
  }
}

variable "master_innodb_buffer_pool_size" {
  description = "InnoDB buffer pool size for master instance"
  type        = string
  default     = "1G"
}

variable "replica_innodb_buffer_pool_size" {
  description = "InnoDB buffer pool size for replica instances"
  type        = string
  default     = "1G"
}

variable "master_placement_attributes" {
  description = "Placement attributes for master provider selection"
  type        = map(string)
  default     = {}
}

variable "replica_placement_attributes" {
  description = "Placement attributes for replica provider selection"
  type        = map(string)
  default     = {}
}

variable "master_pricing_amount" {
  description = "Maximum price for master deployment in uakt"
  type        = number
  default     = 10000
}

variable "replica_pricing_amount" {
  description = "Maximum price for replica deployments in uakt"
  type        = number
  default     = 10000
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)

  validation {
    condition = alltrue([
      for provider in var.allowed_providers :
      can(regex("^akash[0-9a-z]{39}$", provider))
    ])
    error_message = "Invalid Akash provider address format"
  }
}

# Metrics Configuration
variable "metrics_enabled" {
  description = "Enable Prometheus metrics export"
  type        = bool
  default     = false
}

variable "metrics_port" {
  description = "Port for Prometheus metrics"
  type        = number
  default     = 9104
}

# Etcd Configuration
variable "etc_endpoints" {
  description = "List of etcd endpoints"
  type        = list(string)
  default     = []
}

variable "etc_username" {
  description = "Username for etcd authentication"
  type        = string
  default     = "root"
}

variable "etc_password" {
  description = "Password for etcd authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
