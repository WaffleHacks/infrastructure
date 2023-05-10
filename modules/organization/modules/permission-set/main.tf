terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
  }
}

resource "aws_ssoadmin_permission_set" "permission" {
  instance_arn = var.instance_arn

  name        = var.name
  description = var.description

  session_duration = "PT${var.duration}H"
}

resource "aws_ssoadmin_managed_policy_attachment" "policy" {
  for_each = toset(var.policies)

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission.arn
  managed_policy_arn = each.key
}
