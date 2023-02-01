###
### Allows generating AWS credentials based on the user's metadata
###

path "aws/creds/{{identity.entity.metadata.aws_role}}" {
  capabilities = ["read", "update"]
}
