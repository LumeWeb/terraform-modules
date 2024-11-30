variable "cluster_enabled" {
  description = "Enable cluster mode"
  type        = bool
  default     = false
}

variable "cluster_token" {
  description = "Initial cluster token"
  type        = string
  default     = ""
}

variable "cluster_peers" {
  description = "List of cluster peer addresses"
  type        = list(string)
  default     = []
}

variable "metrics_enabled" {
  description = "Enable metrics endpoint"
  type        = bool
  default     = false
}

variable "ports" {
  description = "Port configuration"
  type = object({
    client = optional(number, 2379)
    peer = optional(number, 2380)
    metrics = optional(number, 2381)
  })
  default = {}

  validation {
    condition = alltrue([
      var.ports.client >= 1024 && var.ports.client <= 65535,
      var.ports.peer >= 1024 && var.ports.peer <= 65535,
      var.ports.metrics >= 1024 && var.ports.metrics <= 65535
    ])
    error_message = "All ports must be between 1024 and 65535"
  }
}
