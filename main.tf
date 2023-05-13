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
    google = {
      source  = "hashicorp/google"
      version = "~> 4.64.0"
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
  region = var.aws.region

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

provider "google" {
  project = var.google.project
  region  = var.google.region
}

# Handle configuring the organization accounts
module "organization" {
  source = "./modules/organization"
}

# Creates an federated identity provider for GitHub Actions using OpenID Connect
# Handles both Google and AWS
module "github_actions" {
  source = "./modules/github-actions"
}

module "application_portal" {
  source = "./modules/application-portal"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  github_actions_provider = module.github_actions.aws
}

module "mailer" {
  source = "./modules/mailer"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  github_actions_provider = module.github_actions.aws
}
