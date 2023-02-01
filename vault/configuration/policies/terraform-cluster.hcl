###
### Allow the cluster terraform project to provision its necessary resources
###

# Manages an AWS role for backing up the storage node
path "aws/roles/cluster-storage-backup" {
  capabilities = ["create", "read", "update", "delete"]
  allowed_parameters = {
    credential_type = ["assume_role"]
  }
}

# Manages an AppRole for backing up the storage node
path "auth/approle/role/cluster-storage-backup" {
  capabilities = ["create", "read", "update", "delete"]
  allowed_parameters = {
    policies = ["aws-credentials"]
    token_max_ttl = ["15m"]
  }
}
path "auth/approle/role/cluster-storage-backup/secret-id" {
  capabilities = ["create", "list"]
  allowed_parameters = {
    metadata = ["{\"aws_role\":\"cluster-storage-backup\"}"]
  }
} 
