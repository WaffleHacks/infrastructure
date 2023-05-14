output "email" {
  value       = google_service_account.github_publish.email
  description = "The email of the service account to use for publishing to GitHub"
}
