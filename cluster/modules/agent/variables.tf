variable "region" {
  type        = string
  description = "The region to deploy resources in"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "ssh_key" {
  type        = string
  description = "The ID of the SSH key to use for the node"
}

variable "join_token" {
  type        = string
  description = "The token to use to join the node to the cluster"
}

variable "master_ip" {
  type        = string
  description = "The IP address of the master node"
}
