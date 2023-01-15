module "github_actions_provider" {
  source = "./modules/openid-connect-provider"

  url      = "https://token.actions.githubusercontent.com"
  audience = "sts.amazonaws.com"
}

resource "aws_iam_role" "packer" {
  name = "HashiCorpPacker"
  path = local.infra_role_path

  assume_role_policy = data.aws_iam_policy_document.packer_trust_relationship.json
}

resource "aws_iam_role_policy" "packer" {
  name = "HashiCorpPacker"
  role = aws_iam_role.packer.id

  policy = data.aws_iam_policy_document.packer.json
}
