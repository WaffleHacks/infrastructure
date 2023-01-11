#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

set -eux -o pipefail

# Download the signing key
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install vault
sudo apt-get update
sudo apt-get install -y vault=${VAULT_VERSION}

# Remove the default configuration file to substitute it with our own upon instance creation
sudo rm -f /etc/vault.d/vault.hcl

# Run on startup
sudo systemctl enable vault
