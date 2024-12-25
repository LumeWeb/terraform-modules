variable "name" {
  description = "Name for the Prometheus service"
  type        = string
  default     = "prometheus"
}

variable "image" {
  description = "Prometheus container image"
  type        = string
  default     = "ghcr.io/lumeweb/akash-prometheus:develop"
}

variable "cpu_units" {
  description = "CPU units for the service"
  type        = number
  default     = 1
}

variable "memory_size" {
  description = "Memory size for the service"
  type        = number
  default     = 1
}

variable "memory_unit" {
  description = "Memory unit (Gi, Mi)"
  type        = string
  default     = "Gi"
}

variable "storage_size" {
  description = "Storage size for the service"
  type        = number
  default     = 1
}

variable "storage_unit" {
  description = "Storage unit (Gi, Mi)"
  type        = string
  default     = "Gi"
}

variable "persistent_storage" {
  description = "Persistent storage configuration"
  type = object({
    size = number
    unit = string
    class = string
  })
  default = null
}

variable "prometheus_admin_username" {
  description = "Prometheus admin username"
  type        = string
  default     = "admin"
}

variable "prometheus_admin_password" {
  description = "Prometheus admin password"
  type        = string
  sensitive   = true
}

variable "prometheus_config_file" {
  description = "Prometheus configuration file"
  type        = string
  default     = "/prometheus.yml"
}

variable "prometheus_data_dir" {
  description = "Prometheus data directory"
  type        = string
  default     = "/data"
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket"
  type        = string
}

variable "s3_endpoint" {
  description = "S3 endpoint"
  type        = string
}

variable "backup_schedule" {
  description = "Backup schedule"
  type        = string
  default     = "0 0 * * *"
}

variable "retention_days" {
  description = "Retention days"
  type        = number
  default     = 30
}

variable "max_disk_usage_percent" {
  description = "Max disk usage percent"
  type        = number
  default     = 80
}

variable "promster_log_level" {
  description = "Promster log level"
  type        = string
  default     = "info"
}

variable "promster_scrape_etcd_url" {
  description = "Promster scrape etcd URL"
  type        = string
}

variable "promster_etcd_base_path" {
  description = "Promster etcd base path"
  type        = string
}

variable "promster_etcd_username" {
  description = "Promster etcd username"
  type        = string
}

variable "promster_etcd_password" {
  description = "Promster etcd password"
  type        = string
  sensitive   = true
}

variable "promster_etcd_timeout" {
  description = "Promster etcd timeout"
  type        = string
  default     = "30s"
}

variable "promster_scrape_etcd_paths" {
  description = "List of base ETCD paths for getting servers to be scrapped"
  type        = list(string)
}

variable "promster_scrape_interval" {
  description = "Prometheus scrape interval"
  type        = string
  default     = "30s"
}

variable "promster_scrape_timeout" {
  description = "Prometheus scrape timeout"
  type        = string
  default     = "30s"
}

variable "promster_evaluation_interval" {
  description = "Prometheus evaluation interval"
  type        = string
  default     = "30s"
}

variable "promster_scheme" {
  description = "Scrape scheme, either http or https"
  type        = string
  default     = "http"
}

variable "promster_tls_insecure" {
  description = "Disable validation of the server certificate. true or false"
  type        = string
  default     = "false"
}

variable "placement_attributes" {
  description = "Placement attributes for provider selection"
  type        = map(string)
  default     = {}
}

variable "allowed_providers" {
  description = "List of allowed Akash provider addresses"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "pricing_amount" {
  description = "Pricing amount"
  type        = number
  default     = 10000
}
