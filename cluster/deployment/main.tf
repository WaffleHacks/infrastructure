terraform {
  required_version = ">= 1.3.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.32.0"
    }
    linode = {
      source  = "linode/linode"
      version = "~> 1.29.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "linode" {
  token = var.linode_token
}
