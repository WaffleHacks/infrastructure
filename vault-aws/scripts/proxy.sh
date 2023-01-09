#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

set -eux -o pipefail

# Install nginx
sudo apt-get install -y nginx
sudo systemctl enable nginx

# Disable default site
sudo unlink /etc/nginx/sites-enabled/default

# Register the vault site
sudo cat <<EOF > /etc/nginx/sites-available/vault
server {
  listen 80;
  listen [::]:80;

  location / {
    proxy_pass http://127.0.0.1:8200;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto http;
  }
}
EOF
sudo ln -s /etc/nginx/sites-available/vault /etc/nginx/sites-enabled/vault
