# Each entry represents a DNS record, an ingress rule, and (if `access` is set) an Access app.
#
#   subdomain        -> <subdomain>.<domain>
#   service          -> container address on the shared `tunnel` docker network
#   access           -> policy names from local.access_policies in groups.tf; empty = public
#   session_duration -> how long an Access login lasts (default 24h)
#   type             -> Access app type (default self_hosted); "ssh" adds a browser terminal
locals {
  services = {
    # immich = {
    #   name             = "Immich"
    #   subdomain        = "photos"
    #   service          = "http://immich-server:2283"
    #   access           = ["family"]
    #   session_duration = "720h"
    # }
    dailyoffice = {
      name      = "Daily Office"
      subdomain = "office"
      service   = "http://dailyoffice:8000"
      access    = ["admins"]
    }
    ssh = {
      name      = "SSH"
      subdomain = "ssh"
      service   = "ssh://host.docker.internal:22"
      access    = ["admins"]
      type      = "ssh"
    }
    anylist-mcp = {
      name      = "Anylist MCP"
      subdomain = "anylist-mcp"
      service   = "http://anylist-mcp:3000"
    }

    # blog = {
    #   name      = "Blog"
    #   subdomain = "blog"
    #   service   = "http://blog:80"
    #   # no access, so it's public
    # }
  }
}

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
}
