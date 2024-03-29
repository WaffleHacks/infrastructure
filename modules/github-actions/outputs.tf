output "aws" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "The AWS ARN of the OpenID Connect Provider"
}

output "google" {
  value = {
    id       = google_iam_workload_identity_pool.github.name
    provider = google_iam_workload_identity_pool_provider.github_actions.name
  }
  description = "The Google ID of the Workload Identity pool and Workload Identity pool provider"
}
