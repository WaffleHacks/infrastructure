# The Cloudflare API token with the following permissions on the domain:
#   Zone:DNS:Edit
#   Zone:Origin Rules:Edit
#   Zone:SSL and Certificates:Edit
cloudflare_token = "your-token-here"

# HashiCorp Cloud Platform service principal key client ID and secret
hcp_client_id     = "your-client-id-here"
hcp_client_secret = "your-client-secret-here"

# The region to deploy resources to
region = "us-west-2"

# The HCP Packer Registry bucket and channel to use
packer_bucket  = "vault"
packer_channel = "stable"

# The DynamoDB table to store Vault's state in
dynamodb_table = "vault-storage"

# The domain and subdomain Vault should be accessible at
domain    = "your.domain"
subdomain = "vault"

# Allow connecting to the instance over SSH
enable_ssh = false
