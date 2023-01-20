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
