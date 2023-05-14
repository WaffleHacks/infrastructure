terraform {
  required_version = ">= 1.4.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.64.0"
    }
  }
}

resource "google_service_account" "github_publish" {
  account_id = "${var.github.name}-publish"

  display_name = "${var.github.name} Publish"
  description  = "Allows publishing built images to Artifact Registry from ${var.github.owner}/${var.github.name}"
}

data "google_iam_policy" "workload_identity" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = ["principalSet://iam.googleapis.com/${var.workload_identity_pool_id}/attribute.repository/${var.github.owner}/${var.github.name}"]
  }
}

resource "google_service_account_iam_policy" "workload_identity" {
  service_account_id = google_service_account.github_publish.name

  policy_data = data.google_iam_policy.workload_identity.policy_data
}

resource "google_artifact_registry_repository_iam_binding" "service_account" {
  project    = var.repository.project
  location   = var.repository.location
  repository = var.repository.name

  role    = "roles/artifactregistry.writer"
  members = [google_service_account.github_publish.member]
}
