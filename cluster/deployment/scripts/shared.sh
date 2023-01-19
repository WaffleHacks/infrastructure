#!/usr/bin/env bash

ARCH=$(dpkg --print-architecture)
CODENAME=$(lsb_release -cs)

function install_dependencies {
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
}

function setup_docker_repository {
  # Setup the Docker APT repository

  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $CODENAME stable" > /etc/apt/sources.list.d/docker.list
  apt-get update
}

function install_docker {
  # Install Docker and enable it on boot

  DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io

  systemctl enable docker.service
  systemctl enable containerd.service
}

function setup_hashicorp_repository {
  # Setup the HashiCorp APT repository

  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $CODENAME main" > /etc/apt/sources.list.d/hashicorp.list
  apt-get update
}

function install_consul {
  # Install Consul and Consul Template

  [ ! -n "$2" ] && {
    printf "install_consul(): missing Consul version and Consul Template version\n"
    return 1;
  }

  DEBIAN_FRONTEND=noninteractive apt-get install -y consul=$1 consul-template=$2
}

function install_nomad {
  # Install Nomad

  [ ! -n "$1" ] && {
    printf "install_nomad(): missing Nomad version\n"
    return 1;
  }

  DEBIAN_FRONTEND=noninteractive apt-get install -y nomad=$1
}

function system_setup {
  # Setup the system
  #
  # Requires the following arguments:
  #   $1: Consul version
  #   $2: Consul template version
  #   $3: Nomad version

  [ ! -n "$3" ] && {
    printf "system_setup(): missing Consul version, Consul Template version and Nomad version\n"
    return 1;
  }

  install_dependencies

  setup_docker_repository
  install_docker

  setup_hashicorp_repository
  install_consul $1 $2
  install_nomad $3

  printf "system_setup(): complete\n"
}
