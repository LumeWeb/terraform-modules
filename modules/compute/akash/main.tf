resource "akash_deployment" "service" {
  depends_on = [null_resource.sdl_debug]
  sdl = yamlencode(local.generated_sdl)
  provider_filters {
    providers = var.allowed_providers
    enforce = true
  }
}

resource "null_resource" "sdl_debug" {
  count = var.debug.enabled ? 1 : 0

  triggers = {
    # Add triggers to ensure the debug runs when content changes
    sdl_hash = sha256(jsonencode(local.generated_sdl))
    services_hash = sha256(jsonencode(local.service_config))
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Generated SDL:" > ${local.debug_file}
      echo "---" >> ${local.debug_file}
      echo '${yamlencode(local.generated_sdl)}' >> ${local.debug_file}
      echo "Services input:" >> ${local.debug_file}
      echo '${yamlencode(local.service_config)}' >> ${local.debug_file}
    EOT
  }
}