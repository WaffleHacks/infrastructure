###
### Allows accessing and managing shared passwords
###

# Allow viewing passwords at the root
path "passwords/metadata/" {
  capabilities = ["list"]
}

# Allow read-write access to operations team passwords
path "passwords/data/operations/*" {
  capabilities = ["create", "read", "update"]
}
path "passwords/metadata/operations/*" {
  capabilities = ["list", "read"]
}

# Allow read-write access to p & c team passwords
path "passwords/data/people-and-communications/*" {
  capabilities = ["create", "read", "update"]
}
path "passwords/metadata/people-and-communications/*" {
  capabilities = ["list", "read"]
}

# Allow read-write access to technology team passwords
path "passwords/data/technology/*" {
  capabilities = ["create", "read", "update"]
}
path "passwords/metadata/technology/*" {
  capabilities = ["list", "read"]
}
