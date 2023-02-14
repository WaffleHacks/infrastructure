terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.52.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.12.0"
    }
  }
}

locals {
  versions = {
    wal_g = "2.0.1"
  }
}

resource "random_string" "suffix" {
  length = 6

  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "random_password" "join_token" {
  length = 48

  lower   = true
  upper   = true
  numeric = true
  special = false
}

data "vault_kv_secret_v2" "digitalocean_ccm" {
  mount = "services"
  name  = "digitalocean-ccm"
}

resource "digitalocean_droplet" "instance" {
  name = "storage-${random_string.suffix.result}"

  size   = "s-1vcpu-2gb-amd"
  image  = "debian-11-x64"
  region = var.region.digitalocean

  ipv6     = true
  vpc_uuid = var.vpc.id

  backups       = false
  monitoring    = false
  droplet_agent = false

  ssh_keys = [var.ssh_key]
  tags     = ["storage", "cluster"]

  user_data = templatefile("${path.module}/user-data/script.sh", {
    versions = local.versions

    cidr = var.vpc.cidr

    join_token = random_password.join_token.result

    postgres_config = file("${path.module}/user-data/postgresql.conf")
    postgres_wal_config = templatefile("${path.module}/user-data/wal-g/env", {
      vault = {
        address = var.vault_address

        role_id   = vault_approle_auth_backend_role.backup.role_id
        secret_id = vault_approle_auth_backend_role_secret_id.backup.secret_id
      }

      aws_region = var.region.aws
      s3_bucket  = aws_s3_bucket.backup.bucket
    })
    postgres_wal_backup_script  = file("${path.module}/user-data/wal-g/wal.sh")
    postgres_full_backup_script = file("${path.module}/user-data/wal-g/full.sh")

    manifest_digitalocean_ccm = templatefile("${path.module}/user-data/manifests/digitalocean-ccm.yaml", {
      digitalocean_access_token = data.vault_kv_secret_v2.digitalocean_ccm.data["access-token"]

      vpc_id = var.vpc.id
    })
  })
}
