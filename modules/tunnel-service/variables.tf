variable "account_id" {
  type        = string
  description = "cloudflare account id"
}
variable "zone_id" {
  type        = string
  description = "cloudflare dns zone id for your domain"
}
variable "tunnel_id" {
  type        = string
  description = "cloudflare tunnel id this will connect to"
}
variable "hostname" {
  type        = string
  description = "the hostname for this service"
} # "photos.example.com"

variable "service" {
  type        = string
  description = "path to service on docker network, e.g. https://immich-server:2283"
} # "http://immich-server:2283"

variable "name" {
  type        = string
  description = "name of service"
}

variable "access_policy_ids" {
  type    = list(string)
  default = [] # empty = no Access, publicly reachable
}

variable "app_type" {
  type        = string
  description = "access application type; \"ssh\" adds a browser-rendered terminal"
  default     = "self_hosted"
}

variable "session_duration" {
  type    = string
  default = "24h"
}

variable "service_token" {
  type        = bool
  description = "create an Access service token (and non_identity policy) so apps can authenticate with headers"
  default     = false
}

variable "service_token_header" {
  type        = string
  description = "optional single header name that carries the service token as JSON, for clients that can only send one header"
  default     = null
}

variable "service_token_duration" {
  type        = string
  description = "service token lifetime, e.g. \"8760h\" or \"forever\""
  default     = "8760h"
}
