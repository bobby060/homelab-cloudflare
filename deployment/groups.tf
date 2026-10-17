resource "cloudflare_zero_trust_access_group" "admins" {
  account_id = var.account_id
  name       = "admins"
  include    = [for e in var.admin_emails : { email = { email = e } }]
}

resource "cloudflare_zero_trust_access_group" "family" {
  account_id = var.account_id
  name       = "family"
  include    = [for e in var.family_emails : { email = { email = e } }]
}

resource "cloudflare_zero_trust_access_policy" "admins_only" {
  account_id = var.account_id
  name       = "admins only"
  decision   = "allow"
  include    = [{ group = { id = cloudflare_zero_trust_access_group.admins.id } }]
}

resource "cloudflare_zero_trust_access_policy" "family" {
  account_id = var.account_id
  name       = "family"
  decision   = "allow"
  include = [
    { group = { id = cloudflare_zero_trust_access_group.admins.id } },
    { group = { id = cloudflare_zero_trust_access_group.family.id } },
  ]
}

# Names that services in apps.tf can reference under `access`
locals {
  access_policies = {
    admins = cloudflare_zero_trust_access_policy.admins_only.id
    family = cloudflare_zero_trust_access_policy.family.id
  }
}
