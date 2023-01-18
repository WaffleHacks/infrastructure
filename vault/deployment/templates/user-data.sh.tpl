#!/usr/bin/env bash

cat <<EOF > /etc/vault.d/vault.hcl
log_level = "Info"
ui        = true

listener "tcp" {
  address = "[::]:8200"
  
  tls_cert_file = "/etc/vault.d/cloudflare.crt"
  tls_key_file  = "/etc/vault.d/cloudflare.key"
}

storage "dynamodb" {
  region = "${region}"
  table  = "${dynamodb_table}"

  ha_enabled = "true"
}

seal "awskms" {
  region     = "${region}"
  kms_key_id = "${kms_key}"
}

api_addr = "https://${domain}"

disable_clustering = true
disable_mlock      = false
EOF

/etc/cron.weekly/update-origin-certificate.sh

systemctl start vault
systemctl enable vault
