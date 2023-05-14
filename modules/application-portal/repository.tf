resource "google_artifact_registry_repository" "portal" {
  repository_id = "application-portal"
  description   = "Components of the WaffleHacks application portal"

  format = "DOCKER"
  mode   = "STANDARD_REPOSITORY"
}

resource "google_artifact_registry_repository_iam_binding" "all_users" {
  project    = google_artifact_registry_repository.portal.project
  location   = google_artifact_registry_repository.portal.location
  repository = google_artifact_registry_repository.portal.name

  role    = "roles/artifactregistry.reader"
  members = ["allUsers"]
}

module "service_account" {
  source = "../image-registry-service-account"

  repository                = google_artifact_registry_repository.portal
  workload_identity_pool_id = var.github_actions_provider.id

  github = {
    owner = "WaffleHacks"
    name  = "application-portal"
  }
}

resource "doppler_secret" "repository" {
  for_each = {
    "GOOGLE_SERVICE_ACCOUNT"            = module.service_account.email
    "GOOGLE_WORKLOAD_IDENTITY_PROVIDER" = var.github_actions_provider.provider
  }

  project = "application-portal"
  config  = "gha"

  name  = each.key
  value = each.value
}
