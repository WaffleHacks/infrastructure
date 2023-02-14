###
### Allow the cluster terraform project to provision its necessary resources
###

# Allow issuing limited child tokens
path "auth/token/create" {
  capabilities = ["create", "update"]
}

# Manages an AWS role for backing up the storage node
path "aws/roles/cluster-storage-backup" {
  capabilities = ["create", "read", "update", "delete"]
  allowed_parameters = {
    credential_type = ["assumed_role"]
    role_arns = []
  }
}

# Manages an AppRole for backing up the storage node
path "auth/approle/role/cluster-storage-backup" {
  capabilities = ["create", "read", "update", "delete"]
  allowed_parameters = {
    bind_secret_id = [true]

    token_type = ["default"]
    token_ttl = []
    token_max_ttl = []
    token_policies = [["aws-credentials"]]
  }
}
path "auth/approle/role/cluster-storage-backup/role-id" {
  capabilities = ["read"]
}
path "auth/approle/role/cluster-storage-backup/secret-id" {
  capabilities = ["create", "update"]
  allowed_parameters = {
    metadata = ["{\"aws_role\":\"cluster-storage-backup\"}"]
  }
}
path "auth/approle/role/cluster-storage-backup/secret-id-accessor/lookup" {
  capabilities = ["update"]
}
path "auth/approle/role/cluster-storage-backup/secret-id-accessor/destroy" {
  capabilities = ["update"]
}

# Generate AppRole secret ID for the External Secrets Operator
path "auth/approle/role/cluster-external-secrets/secret-id" {
  capabilities = ["create", "update"]
}
path "auth/approle/role/cluster-external-secrets/secret-id-accessor/lookup" {
  capabilities = ["update"]
}
path "auth/approle/role/cluster-external-secrets/secret-id-accessor/destroy" {
  capabilities = ["update"]
}

# Allow reading services/digitalocean-ccm for initializing the cluster before
# external-secrets is installed
path "services/data/digitalocean-ccm" {
  capabilities = ["read"]
}
