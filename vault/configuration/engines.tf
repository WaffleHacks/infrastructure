resource "vault_mount" "passwords" {
  path    = "passwords"
  type    = "kv"
  options = { version = "v2" }

  description = "Shared passwords for various services"
}

resource "vault_kv_secret_backend_v2" "passwords" {
  path = vault_mount.passwords.path

  max_versions = 0 # unlimited
  cas_required = true
}
