resource "aws_ssoadmin_permission_set" "view_only" {
  instance_arn = local.instance_arn

  name        = "ViewOnlyAccess"
  description = "Allows viewing resources and basic metadata across all services"

  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "view_only" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.view_only.arn
}

resource "aws_ssoadmin_permission_set" "billing" {
  instance_arn = local.instance_arn

  name        = "Billing"
  description = "Allows viewing billing information"

  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "billing" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
  permission_set_arn = aws_ssoadmin_permission_set.billing.arn
}

resource "aws_ssoadmin_permission_set" "admin" {
  instance_arn = local.instance_arn

  name        = "AdministratorAccess"
  description = "Allows full access to all resources"

  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}
