variable "name" {
  description = "Name for the etcd service"
  type        = string

  default     = "etcd"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens"
  }
}

variable "root_password" {
  description = "Root password for etcd authentication"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.root_password) >= 8
    error_message = "Root password must be at least 8 characters long"
  }
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "persistent_storage_size" {
  description = "Persistent storage size"
  type        = number
  default     = 1
}

variable "persistent_storage_unit" {
  description = "Persistent storage unit (Mi, Gi)"
  type        = string
  default     = "Gi"
}

variable "persistent_storage_class" {
  description = "Storage class for persistent volume"
  type        = string
  default     = "beta3"
}
