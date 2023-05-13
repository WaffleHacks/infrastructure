output "aws" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "The AWS ARN of the OpenID Connect Provider"
}

output "google" {
  value       = google_iam_workload_identity_pool.github.id
  description = "The Google ID of the Workload Identity Pool"
}
