terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
  }
}

locals {
  repositories = length(var.subrepositories) > 0 ? [for repository in var.subrepositories : "${var.name}-${repository}"] : [var.name]
  role_name    = join("", [for segment in split("-", var.name) : title(segment)])
}

resource "aws_ecrpublic_repository" "repository" {
  for_each = toset(local.repositories)

  repository_name = each.key

  catalog_data {
    architectures     = ["x86-64"]
    description       = var.description
    operating_systems = ["Linux"]
  }
}

resource "aws_iam_role" "publish" {
  name = "${local.role_name}Publish"
  path = "/ecr"

  assume_role_policy = data.aws_iam_policy_document.publish_trust_relationship.json
}

resource "aws_iam_role_policy" "publish" {
  name = "Publish"
  role = aws_iam_role.publish.id

  policy = data.aws_iam_policy_document.publish.json
}
