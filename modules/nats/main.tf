terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"

      configuration_aliases = [aws.us_east_1]
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.2.2"
    }
  }
}

module "service_account" {
  source = "../image-registry-service-account"

  workload_identity_pool_id = var.github_actions_provider.id

  github = {
    owner = "WaffleHacks"
    name  = "nats"
  }
}

resource "doppler_secret" "repository" {
  for_each = {
    "GOOGLE_SERVICE_ACCOUNT"            = module.service_account.email
    "GOOGLE_WORKLOAD_IDENTITY_PROVIDER" = var.github_actions_provider.provider
  }

  project = "nats"
  config  = "gha"

  name  = each.key
  value = each.value
}

