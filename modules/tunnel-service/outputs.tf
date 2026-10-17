# Returned separately (not as one object) so the root can build the ingress rule;
# the provider rejects a whole ingress object passed through a module output.
output "hostname" {
  value = var.hostname
}

output "service" {
  value = var.service
}
