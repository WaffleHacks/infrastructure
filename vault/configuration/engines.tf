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

resource "vault_mount" "consul" {
  path = "consul"
  type = "consul"

  description = "Generate Consul API tokens dynamically"
}

resource "vault_mount" "nomad" {
  path = "nomad"
  type = "nomad"

  description = "Generate Nomad API tokens dynamically"
}
