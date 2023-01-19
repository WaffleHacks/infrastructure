# Vault

Provisions a [HashiCorp Vault](https://www.vaultproject.io) instance on [AWS](https://aws.amazon.com) behind [Cloudflare](https://www.cloudflare.com).

### Directories

- `/configuration` - manages the configuration of the Vault instance
- `/deployment` - manages the underlying infrastructure
- `/image` - builds the base image for the instance

### Configuration ACL

It is expected that the Vault token will have the following ACL:

```hcl
# Allow issuing limited child tokens
path "auth/token/create" {
  capabilities = ["create", "update"]
}

# Manage secret engines
path "sys/mounts" {
  capabilities = ["read"]
}
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete"]
}

# Manage authentication methods
path "sys/auth" {
  capabilities = ["read"]
}
path "sys/auth/*" {
  capabilities = ["sudo", "create", "read", "update", "delete"]
}

# Manage ACL policies
path "sys/policy" {
  capabilities = ["read"]
}
path "sys/policy/+" {
  capabilities = ["create", "read", "update", "delete"]
}
path "sys/policies/acl" {
  capabilities = ["list"]
}
path "sys/policies/acl/+" {
  capabilities = ["create", "read", "update", "delete"]
}

# Manage identity groups
path "identity/group" {
  capabilities = ["create"]
}
path "identity/lookup/group" {
  capabilities = ["update"]
}
path "identity/group/*" {
  capabilities = ["list", "create", "read", "update", "delete"]
}

# Manage identity group aliases
path "identity/group-alias" {
  capabilities = ["create"]
}
path "identity/group-alias/*" {
  capabilities = ["list", "read", "update", "delete"]
}

# Manage shared passwords engine configuration
path "passwords/config" {
  capabilities = ["read", "update"]
}
```
