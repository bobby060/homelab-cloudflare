resource "cloudflare_dns_record" "this" {
  zone_id = var.zone_id
  name    = var.hostname
  type    = "CNAME"
  content = "${var.tunnel_id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

# Optional service token so non-browser clients (mobile apps, extensions, scripts)
# can get through Access by sending CF-Access-Client-Id / CF-Access-Client-Secret headers.
resource "cloudflare_zero_trust_access_service_token" "this" {
  count      = var.service_token ? 1 : 0
  account_id = var.account_id
  name       = "${var.name} client"
  duration   = var.service_token_duration
}

resource "cloudflare_zero_trust_access_policy" "service_token" {
  count      = var.service_token ? 1 : 0
  account_id = var.account_id
  name       = "${var.name} service token"
  decision   = "non_identity"
  include    = [{ service_token = { token_id = cloudflare_zero_trust_access_service_token.this[0].id } }]
}

locals {
  policy_ids = concat(
    var.access_policy_ids,
    cloudflare_zero_trust_access_policy.service_token[*].id,
  )
}

resource "cloudflare_zero_trust_access_application" "this" {
  count            = length(var.access_policy_ids) > 0 || var.service_token ? 1 : 0
  account_id       = var.account_id
  name             = var.name
  domain           = var.hostname
  type             = var.app_type
  session_duration = var.session_duration

  # Lets clients that can only set one custom header send the token as JSON:
  #   {"cf-access-client-id": "...", "cf-access-client-secret": "..."}
  read_service_tokens_from_header = var.service_token_header

  policies = [for i, id in local.policy_ids : {
    id         = id
    precedence = i + 1
  }]
}

