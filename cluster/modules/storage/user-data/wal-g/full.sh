#!/usr/bin/env bash

set -euxo pipefail

# shellcheck source=scripts/templated/storage/wal-g/env
. /etc/wal-g.d/env

VAULT_TOKEN=$(vault write auth/approle/login role_id="$ROLE_ID" secret_id="$SECRET_ID" | jq -r '.auth.client_token')
export VAULT_TOKEN

CREDENTIALS=$(vault read aws/creds/cluster-storage-backup)
AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS" | jq -r '.data.access_key')
AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.data.secret_key')
AWS_SESSION_TOKEN=$(echo "$CREDENTIALS" | jq -r '.data.security_token')

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN
export WALG_S3_PREFIX="s3://$S3_BUCKET/full"

wal-g backup-push /var/lib/postgresql/15/main
