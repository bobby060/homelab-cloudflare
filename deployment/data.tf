data "cloudflare_zero_trust_tunnel_cloudflared_token" "home" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home.id
}
