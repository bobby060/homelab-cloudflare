module "service" {
  source   = "../modules/tunnel-service"
  for_each = local.services

  account_id        = var.account_id
  zone_id           = var.zone_id
  tunnel_id         = cloudflare_zero_trust_tunnel_cloudflared.home.id
  name              = each.value.name
  hostname          = "${each.value.subdomain}.${var.domain}"
  service           = each.value.service
  access_policy_ids = [for p in try(each.value.access, []) : local.access_policies[p]]
  session_duration  = try(each.value.session_duration, "24h")
  app_type          = try(each.value.type, "self_hosted")

  service_token          = try(each.value.service_token, false)
  service_token_header   = try(each.value.service_token_header, null)
  service_token_duration = try(each.value.service_token_duration, "8760h")
}
