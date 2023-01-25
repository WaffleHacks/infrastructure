# The Cloudflare API token to authenticate with
cloudflare_token = "your-token-here"

# The Cloudflare API token used for Let's Encrypt DNS challenges. Must have the `Zone:Zone:Read` and `Zone:DNS:Edit` permissions.
cloudflare_letsencrypt_token = "your-token-here"

# The Linode API token to authenticate with
linode_token = "your-token-here"

# The Linode API token used for auto-discovering nodes. Must have the `linodes:read` permission.
linode_auto_discovery_token = "your-token-here"

# The region to deploy nodes in
region = "us-central"

# Enable SSH access to the nodes for debugging
enable_ssh = false

# The number of each node type to deploy
controller_count = 1
worker_count     = 2

# The type of node to deploy
controller_type = "g6-standard-2"
worker_type     = "g6-standard-1"

# Whether to use Let's Encrypt staging certificates (for testing)
letsencrypt_staging = false

# The email address to use for Let's Encrypt certificate expiry notifications
letsencrypt_email = "your@email.com"

# Service domain configuration
domain           = "wafflehacks.cloud"
consul_subdomain = "consul"
nomad_subdomain  = "nomad"
