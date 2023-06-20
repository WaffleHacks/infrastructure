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

  github_actions_provider = module.github_actions.google
}

resource "google_artifact_registry_repository" "internal" {
  repository_id = "internal"
  description   = "Internal APIs and services for other WaffleHacks applications"

  format = "DOCKER"
  mode   = "STANDARD_REPOSITORY"
}

resource "google_artifact_registry_repository_iam_binding" "internal_all_users" {
  project    = google_artifact_registry_repository.internal.project
  location   = google_artifact_registry_repository.internal.location
  repository = google_artifact_registry_repository.internal.name

  role    = "roles/artifactregistry.reader"
  members = ["allUsers"]
}

module "mailer" {
  source = "./modules/mailer"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  github_actions_provider = module.github_actions.google
}

module "wafflebot" {
  source = "./modules/wafflebot"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  github_actions_provider = module.github_actions.google
}

module "nats" {
  source = "./modules/nats"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  github_actions_provider = module.github_actions.google
}

resource "google_artifact_registry_repository_iam_binding" "interanl_service_accounts" {
  project    = google_artifact_registry_repository.internal.project
  location   = google_artifact_registry_repository.internal.location
  repository = google_artifact_registry_repository.internal.name

  role = "roles/artifactregistry.writer"
  members = [
    module.nats.service_account_member,
    module.wafflebot.service_account_member,
    module.mailer.service_account_member,
  ]
}
