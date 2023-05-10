output "arn" {
  value       = aws_iam_openid_connect_provider.provider.arn
  description = "The ARN assigned by AWS for this provider."
}
