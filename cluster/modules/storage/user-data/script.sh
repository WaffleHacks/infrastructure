#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# Upgrade system
apt-get update
apt-get upgrade -y

# Install dependencies
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    jq \
    lsb-release \
    software-properties-common

apt-get clean

INSTANCE_ID=$(curl -s http://169.254.169.254/metadata/v1/id)
PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
PUBLIC_IPV6=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv6/address)
PRIVATE_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)

ARCH=$(dpkg --print-architecture)
CODENAME=$(lsb_release -cs)

# Setup HashiCorp APT repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $CODENAME main" > /etc/apt/sources.list.d/hashicorp.list

# Setup PostgreSQL APT repository
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg
echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt $CODENAME-pgdg main" > /etc/apt/sources.list.d/postgresql.list

# Install packages
apt-get update
apt-get install -y postgresql-15 pgbouncer vault

# Install WAL-G
curl -o wal-g -fsSL https://github.com/wal-g/wal-g/releases/download/v${versions.wal_g}/wal-g-pg-ubuntu-20.04-amd64
chmod +x wal-g
mv wal-g /usr/local/bin/

# Configure Postgres
cat <<EOF > /etc/postgresql/15/main/conf.d/server.conf
${postgres_config}
EOF
sed -i 's/local\s*all\s*all\s*peer/local all all trust/g' /etc/postgresql/15/main/pg_hba.conf

# Configure WAL-G
mkdir -p /etc/wal-g.d

cat <<EOF > /etc/wal-g.d/env
${postgres_wal_config}
EOF
cat <<EOF > /etc/wal-g.d/wal.sh
${postgres_wal_backup_script}
EOF
cat <<EOF > /etc/wal-g.d/full.sh
${postgres_full_backup_script}
EOF

chmod +x /etc/wal-g.d/*.sh

echo "0 0 * * * postgres /etc/wal-g.d/full.sh" >> /etc/cron.d/postgres-backup

systemctl enable postgresql
systemctl restart postgresql

# Configure PgBouncer
systemctl stop pgbouncer

cat <<EOF > /etc/pgbouncer/pgbouncer.ini
${pgbouncer_config}
EOF
cat <<EOF > /etc/pgbouncer/pg_hba.conf
# Local connections
local sameuser all scram-sha-256
# Remote connections (ok, protected by firewall)
host sameuser all 0.0.0.0/0 scram-sha-256
host sameuser all ::/0 scram-sha-256
EOF

cat <<EOF > /etc/pgbouncer/setup.sql
${pgbouncer_setup}
EOF

sudo -u postgres createuser \
    --no-superuser \
    --no-createdb \
    --no-createrole \
    --no-replication \
    pgbouncer
sudo -u postgres psql -d postgres -f /etc/pgbouncer/setup.sql

systemctl enable pgbouncer.service
systemctl restart pgbouncer.service

# Add PostgreSQL user for k3s
pg_k3s_password=$(openssl rand -hex 32)
sudo -u postgres createuser \
    --no-superuser \
    --no-createdb \
    --no-createrole \
    --no-replication \
    k3s
sudo -u postgres psql -c "ALTER USER k3s WITH PASSWORD '$pg_k3s_password';"
sudo -u postgres createdb --owner k3s k3s
sudo -u postgres psql -d k3s -f /etc/pgbouncer/setup.sql

# Install k3s
curl -sfL https://get.k3s.io | K3S_TOKEN=${join_token} K3S_DATASTORE_ENDPOINT="postgres://k3s:$pg_k3s_password@127.0.0.1:6432/k3s?sslmode=disable&binary_parameters=yes" sh -s - server --node-ip $PRIVATE_IP --disable traefik --disable servicelb --disable-cloud-controller --kubelet-arg="provider-id=digitalocean://$INSTANCE_ID" --kubelet-arg="cloud-provider=external"
sleep 30

# Allow PgBouncer connections from K3S
k3s_cidr=$(cat /var/lib/rancher/k3s/agent/etc/flannel/net-conf.json | jq -r '.Network')
cat <<EOF >> /etc/pgbouncer/pg_hba.conf
# K3S connections
host sameuser all $k3s_cidr scram-sha-256
EOF

systemctl restart pgbouncer

# Add Vault credentials for External Secret Operator
mkdir -p /var/lib/rancher/k3s/server/manifests/
cat <<EOF > /var/lib/rancher/k3s/server/manifests/vault-credentials.yaml
${manifest_vault_credentials}
EOF

# Deploy DigitalOcean CCM
cat <<EOF > /var/lib/rancher/k3s/server/manifests/digitalocean-ccm.yaml
${manifest_digitalocean_ccm}
EOF

sleep 30

# Deploy Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Argo CD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Add kubeconfig to environment for Argo CD CLI
echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /etc/environment
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Wait for all Argo CD components to be ready
for deployment in $(kubectl get deploy -n argocd -o name); do 
  until kubectl rollout status $deployment -n argocd; do sleep 1; done
done

# Setup Argo CD
kubectl config set-context --current --namespace=argocd
argocd login --core

# Load all apps
argocd app create apps \
  --dest-namespace argocd \
  --dest-server https://kubernetes.default.svc \
  --repo https://github.com/WaffleHacks/infrastructure-manifests.git \
  --path apps

argocd app sync apps

# Ensure components are applied in the correct order
#   - external-secrets
#   - secret-store
#   - cert-manager, external-dns, contour
#   - argocd, governor
#   - everything else
argocd app sync external-secrets
for deployment in $(kubectl get deploy -n external-secrets -o name); do 
  until kubectl rollout status $deployment -n external-secrets; do sleep 1; done
done

argocd app sync secret-store
argocd app sync cert-manager external-dns contour
argocd app sync argocd governor

argocd app sync -l 'app.kubernetes.io/part-of!=infrastructure'
