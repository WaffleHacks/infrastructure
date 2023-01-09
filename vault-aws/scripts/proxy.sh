#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

set -eux -o pipefail

# Install nginx
sudo apt-get install -y nginx
sudo systemctl enable nginx

# Disable default site
sudo unlink /etc/nginx/sites-enabled/default

# Register the vault site
sudo mv /tmp/vault.conf /etc/nginx/sites-available/vault
sudo ln -s /etc/nginx/sites-available/vault /etc/nginx/sites-enabled/vault
