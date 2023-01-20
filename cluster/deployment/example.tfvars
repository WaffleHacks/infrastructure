# The Linode API token to authenticate with
linode_token = "your-token-here"

# The Linode API token used for auto-discovering nodes. Must have the `linodes:read` permission.
linode_auto_discovery_token = "your-token-here"

# The region to deploy nodes in
region = "us-central"

# The number of each node type to deploy
controller_count = 1
worker_count     = 2

# The type of node to deploy
controller_type = "g6-standard-2"
worker_type     = "g6-standard-1"
