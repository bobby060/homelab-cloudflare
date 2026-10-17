resource "cloudflare_dns_record" "this" {
  zone_id = var.zone_id
  name    = var.hostname
  type    = "CNAME"
  content = "${var.tunnel_id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

resource "cloudflare_zero_trust_access_application" "this" {
  count            = length(var.access_policy_ids) > 0 ? 1 : 0
  account_id       = var.account_id
  name             = var.name
  domain           = var.hostname
  type             = var.app_type
  session_duration = var.session_duration

  policies = [for i, id in var.access_policy_ids : {
    id         = id
    precedence = i + 1
  }]
}

