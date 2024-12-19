output "endpoint" {
  description = "Endpoint of the Valkey service"
  value       = format("%s:%s", module.valkey_deployment.provider_host, module.valkey_deployment.port)
}