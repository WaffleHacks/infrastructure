terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

resource "random_string" "suffix" {
  length = 8

  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "digitalocean_droplet" "instance" {
  name = "agent-${random_string.suffix.result}"

  region = var.region
  image  = "debian-11-x64"
  size   = "s-1vcpu-1gb-amd"

  ipv6     = true
  vpc_uuid = var.vpc_id

  backups       = false
  monitoring    = false
  droplet_agent = true

  ssh_keys = [var.ssh_key]

  tags = ["cluster", "agent"]

  user_data = templatefile("${path.module}/user-data/script.sh", {
    master_ip  = var.master_ip
    join_token = var.join_token
  })
}
