output "endpoint" {
  value = "http://${module.prometheus_deployment.provider_host}:${module.prometheus_deployment.port}"
}