terraform {
  required_version = ">= 1.3.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.12.0"
    }
  }

  cloud {
    organization = "wafflehacks"
    workspaces {
      name = "vault-configuration"
    }
  }
}

provider "vault" {
  address = var.address

  auth_login {
    path       = var.auth_path
    parameters = var.auth_parameters
  }
}
