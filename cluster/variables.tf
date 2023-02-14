variable "digitalocean_token" {
  type        = string
  description = "The DigitalOcean API token to authenticate with"
}

variable "region" {
  type = object({
    aws          = string
    digitalocean = string
  })
  description = "The regions to deploy resources in"
}

variable "ssh_key" {
  type        = string
  description = "The name of the SSH key to use for the nodes, must already exist in DigitalOcean"
}

variable "vault_address" {
  type        = string
  description = "The address of the Vault server to use for secrets"
}

variable "vault_auth_path" {
  type        = string
  description = "The path to the authentication method to use"
}

variable "vault_auth_parmeters" {
  type        = map(string)
  description = "The parameters to pass to the authentication method"
}

variable "storage_backup_bucket" {
  type        = string
  description = "The S3 bucket to use for backing up the storage instance"
}
