variable "region" {
  type        = string
  description = "The region to create resources in"
}

variable "cloudflare_token" {
  type        = string
  description = <<EOT
The Cloudflare API token with the following permissions on the domain:
  Zone:DNS:Edit
  Zone:Origin Rules:Edit
  Zone:SSL and Certificates:Edit
EOT
  default     = null
}

variable "hcp_client_id" {
  type        = string
  description = "The HashiCorp Cloud Platform service principal client ID"
  default     = null
}

variable "hcp_client_secret" {
  type        = string
  description = "The HashiCorp Cloud Platform service principal client secret"
  default     = null
}

variable "packer_bucket" {
  type        = string
  description = "The slug of the HCP Packer Registry image bucket to pull from"
}

variable "packer_channel" {
  type        = string
  description = "The channel that points to the version of the HCP Packer image being used"
}

variable "dynamodb_table" {
  type        = string
  description = "The name of the DynamoDB table to use for storage"
}

variable "enable_ssh" {
  type        = bool
  description = "Enable connecting to the instance via SSH"
  default     = false
}

variable "domain" {
  type        = string
  description = "The root domain to add the DNS record to"
}

variable "subdomain" {
  type        = string
  description = "The subdomain the instance should be accessible on"
}
