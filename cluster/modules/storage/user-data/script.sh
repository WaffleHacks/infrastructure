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
    software-properties-common \
    wget

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
apt-get install -y postgresql-15 vault

# Install WAL-G
curl -o wal-g -fsSL https://github.com/wal-g/wal-g/releases/download/v${versions.wal_g}/wal-g-pg-ubuntu-20.04-amd64
chmod +x wal-g
mv wal-g /usr/local/bin/

# Configure Postgres
cat <<EOF > /etc/postgresql/15/main/conf.d/server.conf
${postgres_config}
EOF
cat <<EOF >> /etc/postgresql/15/main/pg_hba.conf
# Internal network
host    all             all             ${cidr}            scram-sha-256
EOF

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

echo "0 0 * * 0 postgres /etc/wal-g.d/full.sh" >> /etc/cron.d/postgres-backup

systemctl enable postgresql
systemctl restart postgresql

# Add PostgreSQL user for k3s
pg_k3s_password=$(openssl rand -hex 32)
sudo -u postgres createuser \
    --no-superuser \
    --no-createdb \
    --no-createrole \
    k3s
sudo -u postgres psql -c "ALTER USER k3s WITH PASSWORD '$pg_k3s_password';"
sudo -u postgres createdb --owner k3s k3s

# Install k3s
curl -sfL https://get.k3s.io | K3S_TOKEN=${join_token} K3S_DATASTORE_ENDPOINT=postgres://k3s:$pg_k3s_password@127.0.0.1:5432/k3s?sslmode=disable sh -s - server --node-ip $PRIVATE_IP --disable traefik --disable servicelb --disable-cloud-controller --kubelet-arg="provider-id=digitalocean://$INSTANCE_ID" --kubelet-arg="cloud-provider=external"
sleep 15

# Add Vault credentials for External Secret Operator
mkdir -p /var/lib/rancher/k3s/server/manifests/
cat <<EOF > /var/lib/rancher/k3s/server/manifests/vault-credentials.yaml
${manifest_vault_credentials}
EOF

# Deploy DigitalOcean CCM
cat <<EOF > /var/lib/rancher/k3s/server/manifests/digitalocean-ccm.yaml
${manifest_digitalocean_ccm}
EOF

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

# Wait for Argo CD to be ready
until kubectl -n argocd rollout status deployment/argocd-server; do sleep 1; done

# Setup Argo CD
kubectl config set-context --current --namespace=argocd
argocd login --core

# Load all apps
argocd app create apps \
  --dest-namespace argocd \
  --dest-server https://kubernetes.default.svc \
  --repo https://github.com/WaffleHacks/infrastructure.git \
  --path manifests/apps

argocd app sync apps

# Ensure components are applied in the correct order
#   - external-secrets
#   - secret-store
#   - everything else
argocd app sync external-secrets
argocd app sync secret-store
argocd app sync -l app.kubernetes.io/instance=apps
