variable "cluster_name" {
  description = "Name of the MySQL cluster"
  type        = string
  default     = "mysql"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.cluster_name))
    error_message = "Cluster name must be lowercase alphanumeric with hyphens"
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "node_count" {
  description = "Number of nodes to deploy in the cluster"
  type        = number
  default     = 3

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "node_count must be between 1 and 10"
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

variable "node_resources" {
  description = "Resource configuration for cluster nodes"
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
  description = "Default resource configuration for all nodes"
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

variable "innodb_buffer_pool_size" {
  description = "InnoDB buffer pool size for nodes"
  type        = string
  default     = "1G"
}

variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type        = map(string)
  default     = {}
}

variable "pricing_amount" {
  description = "Maximum price for node deployment in uakt"
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

variable "backups_enabled" {
  description = "Enable automatic backups"
  type        = bool
  default     = true
}