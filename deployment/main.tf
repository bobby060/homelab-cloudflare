# Assemble ingress (catch-all must be last)
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home.id

  config = {
    ingress = concat(
      [for m in module.service : { hostname = m.hostname, service = m.service }],
      [{ service = "http_status:404" }],
    )
  }
}

resource "random_bytes" "tunnel_secret" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "home" {
  account_id    = var.account_id
  name          = "home-lab"
  config_src    = "cloudflare" # remotely managed
  tunnel_secret = random_bytes.tunnel_secret.base64
}
