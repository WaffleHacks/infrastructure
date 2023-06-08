module "service_account" {
  source = "../image-registry-service-account"

  repository                = var.image_repository
  workload_identity_pool_id = var.github_actions_provider.id

  github = {
    owner = "WaffleHacks"
    name  = "wafflebot"
  }
}

resource "doppler_secret" "repository" {
  for_each = {
    "GOOGLE_SERVICE_ACCOUNT"            = module.service_account.email
    "GOOGLE_WORKLOAD_IDENTITY_PROVIDER" = var.github_actions_provider.provider
  }

  project = "wafflebot"
  config  = "gha"

  name  = each.key
  value = each.value
}
