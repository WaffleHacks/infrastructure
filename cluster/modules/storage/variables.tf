variable "region" {
  type = object({
    aws          = string
    digitalocean = string
  })
  description = "The regions to deploy resources in"
}

variable "vpc" {
  type = object({
    id   = string
    cidr = string
  })
  description = "The details of the VPC"
}

variable "ssh_key" {
  type        = string
  description = "The ID of the SSH key to use for the node"
}

variable "vault_address" {
  type        = string
  description = "The address of the Vault server"
}

variable "backup_bucket" {
  type        = string
  description = "The name of the S3 bucket to store database backups in"

  validation {
    condition     = length(var.backup_bucket) >= 3 && length(var.backup_bucket) <= 63 && can(regex("^[a-z0-9][a-z0-9\\-\\.]*[a-z0-9]$", var.backup_bucket))
    error_message = "Bucket name must follow AWS naming rules: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  }
}
