terraform {
  required_version = ">= 1.3.0"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 1.29.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

provider "linode" {
  token = var.linode_token
}
