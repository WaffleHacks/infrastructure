module "image_repository" {
  source = "../image-repository"
  providers = {
    aws = aws.us_east_1
  }

  name            = "application-portal"
  subrepositories = ["api", "mjml", "tasks"]
  description     = "A component of the WaffleHacks application portal."

  github_repository       = "WaffleHacks/application-portal"
  github_actions_provider = var.github_actions_provider
}

resource "doppler_secret" "github_publish_role" {
  project = "application-portal"
  config  = "gha"

  name  = "AWS_ROLE"
  value = module.image_repository.role_arn
}

resource "google_artifact_registry_repository" "portal" {
  repository_id = "application-portal"
  description   = "Components of the WaffleHacks application portal"

  format = "DOCKER"
  mode   = "STANDARD_REPOSITORY"
}

resource "google_service_account" "github_publish" {
  account_id = "application-portal-publish"

  display_name = "Application Portal Publish"
  description  = "Allows publishing built images to Artifact Registry"
}

resource "google_service_account_iam_binding" "github_publish" {
  service_account_id = google_service_account.github_publish.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com${var.github_actions_provider_google}/attribute.repository/WaffleHacks/application-portal",
  ]
}

data "google_iam_policy" "repository" {
  binding {
    role    = "roles/artifactregistry.writer"
    members = [google_service_account.github_publish.member]
  }

  binding {
    role    = "roles/artifactregistry.reader"
    members = ["allUsers"]
  }
}

resource "google_artifact_registry_repository_iam_policy" "portal" {
  project    = google_artifact_registry_repository.portal.project
  location   = google_artifact_registry_repository.portal.location
  repository = google_artifact_registry_repository.portal.name

  policy_data = data.google_iam_policy.repository.policy_data
}

resource "doppler_secret" "repository" {
  for_each = {
    "GOOGLE_SERVICE_ACCOUNT"            = google_service_account.github_publish.email
    "GOOGLE_WORKLOAD_IDENTITY_PROVIDER" = var.github_actions_provider_google
  }

  project = "application-portal"
  config  = "gha"

  name  = each.key
  value = each.value
}
