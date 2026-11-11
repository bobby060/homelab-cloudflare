# Returned separately (not as one object) so the root can build the ingress rule;
# the provider rejects a whole ingress object passed through a module output.
output "hostname" {
  value = var.hostname
}

output "service" {
  value = var.service
}

output "service_token" {
  value = var.service_token ? {
    client_id     = cloudflare_zero_trust_access_service_token.this[0].client_id
    client_secret = cloudflare_zero_trust_access_service_token.this[0].client_secret
  } : null
  sensitive = true
}
