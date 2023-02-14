resource "vault_mount" "passwords" {
  path = "passwords"
  type = "kv-v2"

  description = "Shared passwords for various services"
}

resource "vault_kv_secret_backend_v2" "passwords" {
  mount = vault_mount.passwords.path

  max_versions = 0 # unlimited
  cas_required = true
}

resource "vault_aws_secret_backend" "aws" {
  path        = "aws"
  description = "Generate AWS credentials on te fly"
}

resource "vault_mount" "services" {
  path = "services"
  type = "kv-v2"

  description = "Credentials and secrets for various cluster services"
}

resource "vault_kv_secret_backend_v2" "services" {
  mount = vault_mount.services.path

  max_versions = 0 # unlimited
  cas_required = true
}
