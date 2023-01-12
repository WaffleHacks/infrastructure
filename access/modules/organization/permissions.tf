module "permission_set_view_only" {
  source = "./modules/permission-set"

  instance_arn = local.instance_arn

  name        = "ViewOnlyAccess"
  description = "Allows viewing resources and basic metadata across all services"

  policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
}

module "permission_set_billing" {
  source = "./modules/permission-set"

  instance_arn = local.instance_arn

  name        = "Billing"
  description = "Allows viewing billing information"

  policies = ["arn:aws:iam::aws:policy/job-function/Billing"]
}

module "permission_set_admin" {
  source = "./modules/permission-set"

  instance_arn = local.instance_arn

  name        = "AdministratorAccess"
  description = "Allows full access to all resources"
  duration    = 1

  policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
