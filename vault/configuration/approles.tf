data "vault_auth_backend" "approle" {
  path = "approle"
}

resource "vault_approle_auth_backend_role" "terraform_cluster" {
  backend = data.vault_auth_backend.approle.path

  role_name = "terraform-cluster"

  token_ttl     = 60 * 15
  token_max_ttl = 60 * 15
  token_policies = [
    vault_policy.policies["terraform-cluster"].name
  ]
}

resource "vault_approle_auth_backend_role_secret_id" "terraform_cluster" {
  backend   = data.vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.terraform_cluster.role_name
}

resource "vault_approle_auth_backend_role" "cluster_external_secrets" {
  backend = data.vault_auth_backend.approle.path

  role_name = "cluster-external-secrets"

  token_ttl     = 60 * 2.5
  token_max_ttl = 60 * 5
  token_policies = [
    vault_policy.policies["cluster-external-secrets"].name
  ]
}
