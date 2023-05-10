output "arns" {
  value       = { for repository in aws_ecrpublic_repository.repository : repository.repository_name => repository.arn }
  description = "Mappings from repository name to ARN"
}

output "role_arn" {
  value       = aws_iam_role.publish.arn
  description = "The ARN of the role used to publish to the repository"
}
