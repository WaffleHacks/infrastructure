#!/usr/bin/env bash

set -euxo pipefail

. /etc/wal-g.d/env

export VAULT_TOKEN=\$(vault write auth/approle/login role_id=\$ROLE_ID secret_id=\$SECRET_ID | jq -r '.auth.client_token')

CREDENTIALS=\$(vault read aws/creds/cluster-storage-backup)
export AWS_ACCESS_KEY_ID=\$(echo \$CREDENTIALS | jq -r '.data.access_key')
export AWS_SECRET_ACCESS_KEY=\$(echo \$CREDENTIALS | jq -r '.data.secret_key')
export AWS_SESSION_TOKEN=\$(echo \$CREDENTIALS | jq -r '.data.security_token')
export WALG_S3_PREFIX="s3://\$S3_BUCKET/wal"

wal-g wal-push \$1
