locals {
  # Get all accept hostnames from the expose configuration
  accept_hostnames = flatten([
    for expose in coalesce(var.service.expose, []) :
    coalesce(expose.accept, [])
  ])

  # Extract service details, handling both structures
  service_details = try(
    akash_deployment.service.services[0],
    {
      for k, v in akash_deployment.service.services :
      k => v if k == local.service_name
    }[local.service_name]
  )

  # Determine if the service is using HTTP/HTTPS ports
  exposed_ports = {
    for expose in coalesce(var.service.expose, []) :
    "${try(coalesce(expose.as, expose.port), expose.port)}-${join("-", coalesce(expose.accept, []))}" => {
      port = try(coalesce(expose.as, expose.port), expose.port)
      is_http = contains([80, 443], try(coalesce(expose.as, expose.port), expose.port))
      accept = coalesce(expose.accept, [])
    }
  }

  # If any exposed port is HTTP/HTTPS, we'll have URIs instead of forwarded ports
  has_http_ports = length([for port, config in local.exposed_ports : config if config.is_http]) > 0

  # URI handling (only when HTTP/HTTPS ports are present)
  uris = local.has_http_ports ? try(local.service_details.uris, []) : []
  is_accepted_uri = local.has_http_ports ? {
    for uri in local.uris :
    uri => contains(local.accept_hostnames, uri)
  } : {}

  # Split deployment ID into components
  id_parts = split(":", akash_deployment.service.id)
}

output "id" {
  description = "The ID of the deployment"
  value = akash_deployment.service.id
}

output "dseq" {
  value = local.id_parts[0]
}

output "gseq" {
  value = local.id_parts[1]
}

output "oseq" {
  value = local.id_parts[2]
}

output "owner" {
  value = local.id_parts[3]
}

output "provider" {
  value = local.id_parts[4]
}

output "state" {
  description = "The current state of the deployment"
  value       = akash_deployment.service.deployment_state
}

output "service_endpoints" {
  description = "All available HTTP/HTTPS URIs (only available when mapped to port 80/443)"
  value       = try(akash_deployment.service.services[0].uris, [])
}

output "dns_fqdn" {
  description = "User-provided FQDN for HTTP/HTTPS service (first URI matching accept list)"
  value = try(
    # Get the first URI that matches an accept hostname
    [for uri in akash_deployment.service.services[0].uris : uri if local.is_accepted_uri[uri]][0],
    ""
  )
}

output "provider_host" {
  description = "Provider-generated hostname"
  value = try(
    coalesce(
      # First try to get provider hostname from URIs
      try(
        [
          for uri in akash_deployment.service.services[0].uris : uri 
          if contains(split(".", uri), "ingress") || contains(split(".", uri), "provider")
        ][0],
        null
      ),
      # Fallback to forwarded ports host if no matching URI
      try(akash_deployment.service.services[0].forwarded_ports[0].host, "")
    ),
    ""
  )
}

output "has_http_ports" {
  description = "Whether the deployment has HTTP/HTTPS ports"
  value = local.has_http_ports
}


output "forwarded_ports" {
  description = "Forwarded ports for the deployment (only available when not using port 80/443)"
  value = try(local.service_details.forwarded_ports, [])
}

output "port" {
  description = "Port for the service (80 if HTTP URIs are present, otherwise first forwarded port)"
  value       = local.has_http_ports ? 80 : try(
    local.service_details.forwarded_ports[0].external_port,
    null
  )
}

output "ips" {
  description = "IP addresses assigned to the deployment"
  value = try(local.service_details.ips, [])
}
