#!/usr/bin/env bash
#
#
#<UDF name="consul_version" label="Consul version" />
# CONSUL_VERSION=
#
#<UDF name="consul_template_version" label="Consul template version" />
# CONSUL_TEMPLATE_VERSION=
#
#<UDF name="nomad_version" label="Nomad version" />
# NOMAD_VERSION=
#
#<UDF name="cni_version" label="CNI plugins version" />
# CNI_VERSION=

exec > >(tee -i /var/log/stackscript.log)

set -ex

ARCH=$(dpkg --print-architecture)
CODENAME=$(lsb_release -cs)

# Upgrade system
apt-get update
apt-get upgrade -y

# Install dependencies
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  jq \
  lsb-release \
  unzip \
  wget

apt-get clean

# Setup the Docker APT repository
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $CODENAME stable" > /etc/apt/sources.list.d/docker.list
apt-get update

# Install Docker
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable it on boot
systemctl enable docker.service
systemctl enable containerd.service

# Setup HashiCorp APT repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $CODENAME main" > /etc/apt/sources.list.d/hashicorp.list
apt-get update

# Install Consul, Consul Template and Nomad
DEBIAN_FRONTEND=noninteractive apt-get install -y consul=$CONSUL_VERSION consul-template=$CONSUL_TEMPLATE_VERSION nomad=$NOMAD_VERSION

# Install CNI plugins
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v$CNI_VERSION/cni-plugins-linux-$ARCH-v$CNI_VERSION.tgz"
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf cni-plugins.tgz
rm cni-plugins.tgz

# Configure IP forwarding
echo "net.bridge.bridge-nf-call-arptables = 1" >> /etc/sysctl.d/10-cni.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/10-cni.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/10-cni.conf
sysctl -p

# Generate a random hostname
hostname=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 16)
hostnamectl set-hostname $hostname

# Configure and start consul
cat <<EOF > /etc/consul.d/consul.hcl
${consul_config}
EOF

cat <<EOF > /etc/consul.d/consul.env
LINODE_TOKEN=${auto_discovery_token}
EOF

systemctl enable consul.service
systemctl start consul.service

# Wait for Consul to start
printf "Waiting 15s for Consul to start...\n"
sleep 15

# Configure and start nomad
cat <<EOF > /etc/nomad.d/nomad.hcl
${nomad_config}
EOF

systemctl enable nomad.service
systemctl start nomad.service

# Wait for Nomad to start
printf "Waiting 15s for Nomad to start...\n"
sleep 15

# Run post-setup hook
printf "Running post-setup hook...\n"
${post_setup}

printf "Configuration complete\n"
