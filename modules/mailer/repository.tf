module "image_repository" {
  source = "../image-repository"
  providers = {
    aws = aws.us_east_1
  }

  name        = "mailer"
  description = "A generic email interface for all WaffleHacks services."

  github_repository       = "WaffleHacks/mailer"
  github_actions_provider = var.github_actions_provider_aws
}

resource "doppler_secret" "github_publish_role" {
  project = "mailer"
  config  = "gha"

  name  = "AWS_ROLE"
  value = module.image_repository.role_arn
}

module "service_account" {
  source = "../image-registry-service-account"

  repository                = var.image_repository
  workload_identity_pool_id = var.github_actions_provider.id

  github = {
    owner = "WaffleHacks"
    name  = "mailer"
  }
}

resource "doppler_secret" "repository" {
  for_each = {
    "GOOGLE_SERVICE_ACCOUNT"            = module.service_account.email
    "GOOGLE_WORKLOAD_IDENTITY_PROVIDER" = var.github_actions_provider.provider
  }

  project = "mailer"
  config  = "gha"

  name  = each.key
  value = each.value
}
