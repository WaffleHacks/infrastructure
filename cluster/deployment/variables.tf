variable "cloudflare_token" {
  type        = string
  description = "The Cloudflare API token to authenticate with"
}

variable "cloudflare_letsencrypt_token" {
  type        = string
  description = "The Cloudflare API token used for Let's Encrypt DNS challenges. Must have the `Zone:Zone:Read` and `Zone:DNS:Edit` permissions."
}

variable "linode_token" {
  type        = string
  description = "The Linode API token to authenticate with"
}

variable "linode_auto_discovery_token" {
  type        = string
  description = "The Linode API token used for auto-discovering nodes. Must have the `linodes:read` permission."
}

variable "region" {
  type        = string
  description = "The region to deploy nodes in"
}

variable "controller_type" {
  type        = string
  description = "The type of node to deploy for the controller"
}

variable "controller_count" {
  type        = number
  description = "The number of controller nodes to deploy"
}

variable "worker_type" {
  type        = string
  description = "The type of node to deploy for the workers"
}

variable "worker_count" {
  type        = number
  description = "The number of worker nodes to deploy"
}

variable "enable_ssh" {
  type        = bool
  description = "Enable SSH access to the nodes for debugging"
  default     = false
}

variable "letsencrypt_staging" {
  type        = bool
  description = "Use Let's Encrypt staging environment for testing"
  default     = false
}

variable "letsencrypt_email" {
  type        = string
  description = "The email address to use for Let's Encrypt certificate expiry notifications"
}

variable "domain" {
  type        = string
  description = "The base domain to use for the cluster"
}

variable "consul_subdomain" {
  type        = string
  description = "The subdomain to use for Consul"
  default     = "consul"
}

variable "nomad_subdomain" {
  type        = string
  description = "The subdomain to use for Nomad"
  default     = "nomad"
}
