terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.32.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.52.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
  }

  cloud {
    organization = "wafflehacks"
    workspaces {
      name = "deployment"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      App = "vault"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}
