###
### Allows managing individual users and their aliases
###

# Manage identity entities
path "identity/entity" {
 	capabilities = ["create", "update"]
}
path "identity/lookup/entity" {
  capabilities = ["update"]
}
path "identity/entity/*" {
  capabilities = ["list", "create", "read", "update", "delete"]
}

# Manage identity entity aliases
path "identity/entity-alias" {
  capabilities = ["create"]
}
path "identity/entity-alias/*" {
  capabilities = ["list", "read", "update", "delete"]
}
