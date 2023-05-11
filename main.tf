terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.2.2"
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

provider "doppler" {
  doppler_token = var.doppler_token
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

module "application_portal" {
  source = "./modules/application-portal"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  github_actions_provider = module.github_actions.arn
}
