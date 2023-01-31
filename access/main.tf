terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
  }

  cloud {
    organization = "wafflehacks"
    workspaces {
      name = "access"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "access"
    }
  }
}

# Handle configuring the organization accounts
module "organization" {
  source = "./modules/organization"
}

# Handle roles for external access from 3rd-party services like GitHub Actions
module "external" {
  source = "./modules/external"
}

# Handle provisioning access keys for various services
module "access_keys" {
  source = "./modules/access-keys"
}
