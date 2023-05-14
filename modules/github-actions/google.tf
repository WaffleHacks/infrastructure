resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"

  display_name = "GitHub"
  description  = "Allows workloads from GitHub to access Google Cloud APIs"
}

resource "google_iam_workload_identity_pool_provider" "actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "actions"

  display_name = "GitHub Actions"
  description  = "Allows workloads from GitHub Actions"

  oidc {
    issuer_uri = local.url
    allowed_audiences = [
      "https://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/providers/github-actions"
    ]
  }
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.ref"        = "assertion.ref"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.event"      = "assertion.event_name"
  }
}
