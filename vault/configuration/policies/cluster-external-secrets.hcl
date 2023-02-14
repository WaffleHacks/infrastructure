###
### Allow the cluster to read the services KV engine for importing via the External Secrets Operator
###

path "services/data/*" {
  capabilities = ["read"]
}
