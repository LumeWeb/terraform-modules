# Core MySQL Configuration
variable "cluster_mode" {
  description = "Enable MySQL cluster mode"
  type        = bool
  default     = false
}
variable "root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "mysql_port" {
  description = "MySQL service port"
  type        = number
  default     = 3306
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
  type = list(string)
  default = []
}

variable "etc_username" {
  description = "Username for etcd authentication"
  type        = string
  default     = "root"
  sensitive   = true
}

variable "etc_password" {
  description = "Password for etcd authentication"
  type        = string
  default     = ""
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

# Performance Configuration
variable "innodb_buffer_pool_size" {
  description = "InnoDB buffer pool size"
  type        = string
  default     = "1G"
}

# Server Configuration
variable "server_id" {
  description = "Unique server ID for this instance"
  type        = number
  default     = 1
}

# Resource Configuration (required by Akash)
variable "cpu_units" {
  description = "CPU units for MySQL service"
  type        = number
  default     = 1
}

variable "memory_size" {
  description = "Memory size for MySQL service"
  type        = number
  default     = 2
}

variable "memory_unit" {
  description = "Memory unit (Gi, Mi)"
  type        = string
  default     = "Gi"
}

variable "storage_size" {
  description = "Storage size for MySQL data"
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
  default     = "mysql-placement"
}

variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type = map(string)
  default = {}
}

variable "pricing_amount" {
  description = "Maximum price for deployment in uakt"
  type        = number
  default     = 10000
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type = list(string)
}

# Tags
variable "tags" {
  description = "Resource tags"
  type = map(string)
  default = {}
}
