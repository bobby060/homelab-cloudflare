variable "account_id" {
  type        = string
  description = "cloudflare account id"
}

variable "zone_id" {
  type        = string
  description = "cloudflare dns zone id for your domain"
}

variable "domain" {
  type        = string
  description = "base domain that service subdomains are created under, e.g. example.com"
}

variable "admin_emails" {
  type        = list(string)
  description = "emails allowed through the admins access group"
}

variable "family_emails" {
  type        = list(string)
  description = "emails allowed through the family access group"
  default     = []
}
