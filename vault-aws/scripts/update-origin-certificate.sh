#!/usr/bin/env bash

set -e

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)

aws ssm get-parameter \
  --region $REGION \
  --name /vault/cloudflare/certificate \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > /etc/vault.d/cloudflare.crt

aws ssm get-parameter \
  --region $REGION \
  --name /vault/cloudflare/private-key \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > /etc/vault.d/cloudflare.key

chown vault:vault /etc/vault.d/cloudflare.crt /etc/vault.d/cloudflare.key

systemctl reload vault
