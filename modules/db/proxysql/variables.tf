variable "admin_password" {
  description = "ProxySQL admin password"
  type        = string
  sensitive   = true
}

variable "proxy_port" {
  description = "ProxySQL main frontend port"
  type        = number
  default     = 6033
}

variable "admin_port" {
  description = "ProxySQL admin interface port"
  type        = number
  default     = 6032
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "memory_size" {
  description = "Memory size"
  type        = number
  default     = 512
}

variable "memory_unit" {
  description = "Memory unit (Mi, Gi)"
  type        = string
  default     = "Mi"
}

variable "storage_size" {
  description = "Storage size"
  type        = number
  default     = 1
}

variable "storage_unit" {
  description = "Storage unit (Mi, Gi)"
  type        = string
  default     = "Gi"
}

variable "etcd_endpoints" {
  description = "List of etcd endpoints"
  type        = list(string)
  default     = []
}

variable "etcd_username" {
  description = "Username for etcd authentication"
  type        = string
  default     = "root"
}

variable "etcd_password" {
  description = "Password for etcd authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)
  default     = []
}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
