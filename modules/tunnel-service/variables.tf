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

variable "session_duration" {
  type    = string
  default = "24h"
}

