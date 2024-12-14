output "service_uri" {
  description = "URIs where the portal service is accessible"
  value       = module.portal_deployment.dns_fqdn
}