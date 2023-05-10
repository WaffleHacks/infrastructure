terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
  }

  cloud {
    organization = "wafflehacks"
    workspaces {
      name = "wafflehacks"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}

# Handle configuring the organization accounts
module "organization" {
  source = "./modules/organization"
}

# Creates an federated identity provider for GitHub Actions using OpenID Connect
module "github_actions" {
  source = "./modules/openid-connect-provider"

  url      = "https://token.actions.githubusercontent.com"
  audience = "sts.amazonaws.com"
}
