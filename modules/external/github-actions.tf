module "github_actions_provider" {
  source = "./modules/openid-connect-provider"

  url      = "https://token.actions.githubusercontent.com"
  audience = "sts.amazonaws.com"
}

resource "aws_iam_role" "application_portal_ecr" {
  name = "ApplicationPortalECR"
  path = local.infra_role_path

  assume_role_policy = data.aws_iam_policy_document.application_portal_ecr_trust_relationship.json
}

resource "aws_iam_role_policy" "application_portal_ecr" {
  name = "ApplicationPortalECR"
  role = aws_iam_role.application_portal_ecr.id

  policy = data.aws_iam_policy_document.application_portal_ecr.json
}

resource "aws_iam_role" "mailer_ecr" {
  name = "MailerECR"
  path = local.infra_role_path

  assume_role_policy = data.aws_iam_policy_document.mailer_ecr_trust_relationship.json
}

resource "aws_iam_role_policy" "mailer_ecr" {
  name = "MailerECR"
  role = aws_iam_role.mailer_ecr.id

  policy = data.aws_iam_policy_document.mailer_ecr.json
}
