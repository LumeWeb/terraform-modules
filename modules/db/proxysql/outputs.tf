output "dseq" {
  description = "The ID of the deployment"
  value       = module.deployment.dseq
}

output "endpoint" {
  description = "The endpoint of the deployment"
  value       = "${module.deployment.provider_host}:${module.deployment.port}"
}