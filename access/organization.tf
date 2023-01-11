resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
  aws_service_access_principals = [
    "account.amazonaws.com",
    "sso.amazonaws.com",
  ]
}

data "aws_ssoadmin_instances" "main" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}
