output "tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.home.token
  sensitive = true
}

# terraform output -json service_tokens
output "service_tokens" {
  value     = { for k, m in module.service : k => m.service_token if m.service_token != null }
  sensitive = true
}
