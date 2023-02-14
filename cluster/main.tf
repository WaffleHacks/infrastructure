terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.52.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.26.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.12.0"
    }
  }

  cloud {
    organization = "wafflehacks"
    workspaces {
      name = "cluster"
    }
  }
}

provider "aws" {
  region = var.region.aws

  default_tags {
    tags = {
      Project = "cluster"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

provider "vault" {
  address = var.vault_address

  auth_login {
    path       = var.vault_auth_path
    parameters = var.vault_auth_parmeters
  }
}
