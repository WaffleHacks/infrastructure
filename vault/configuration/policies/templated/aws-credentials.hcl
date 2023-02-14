###
### Allows generating AWS credentials based on the user's metadata
###

path "aws/creds/{{identity.entity.aliases.${approle_mount}.metadata.aws_role}}" {
  capabilities = ["read", "update"]
}
