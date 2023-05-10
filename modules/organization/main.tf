terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
  }
}

resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
  aws_service_access_principals = [
    "account.amazonaws.com",
    "sso.amazonaws.com",
  ]
}
