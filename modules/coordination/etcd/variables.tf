# Resource Configuration
variable "cpu_units" {
  description = "CPU units for etcd service"
  type        = number
  default     = 1000
}

variable "memory_size" {
  description = "Memory size for etcd service"
  type        = number
  default     = 1
}

variable "memory_unit" {
  description = "Memory unit (Gi, Mi)"
  type        = string
  default     = "Gi"
}

variable "storage_size" {
  description = "Storage size for etcd data"
  type        = number
  default     = 10
}

variable "storage_unit" {
  description = "Storage unit (Gi, Mi)"
  type        = string
  default     = "Gi"
}

variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type        = map(string)
  default     = {}
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}