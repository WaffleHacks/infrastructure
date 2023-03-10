# The DigitalOcean API token to authenticate with
digitalocean_token = "your-token-here"

# The connection information to use for Vault
vault_address        = "https://vault.your.domain"
vault_auth_path      = "auth/<method>/login"
vault_auth_parmeters = {}

# The Tailscale configuration
tailscale_api_key = "your-tailscale-api-key-here"
tailscale_tailnet = "tailnet-NNNN.ts.net"

# The regions to deploy resources in
region = {
  aws          = "us-west-1"
  digitalocean = "sfo2"
}

# The name of the SSH key to use for the nodes
ssh_key = "cluster"

# The S3 bucket to use for backing up the storage instance
storage_backup_bucket = "storage-instance-backups"
