output "dns_fqdn" {
  description = "Portal service FQDN endpoint"
  value       = module.portal_deployment.dns_fqdn
}

output "ip_address" {
  description = "Portal service IP address"
  value       = module.portal_deployment.ips[0].ip
}