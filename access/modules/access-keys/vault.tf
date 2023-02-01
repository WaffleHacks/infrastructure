resource "aws_iam_user" "vault" {
  name = "vault"
  path = "/terraform/"

  tags = {
    ChildProject = "vault"
  }
}

resource "aws_iam_access_key" "vault" {
  user   = aws_iam_user.vault.name
  status = "Active"
}

resource "aws_iam_user_policy_attachment" "vault_ec2" {
  user       = aws_iam_user.vault.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "vault_vpc" {
  user       = aws_iam_user.vault.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_user_policy_attachment" "vault_dynamodb" {
  user       = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

resource "aws_iam_user_policy_attachment" "vault_kms" {
  user       = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.kms.arn
}

resource "aws_iam_user_policy_attachment" "vault_iam_instance_profile" {
  user       = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.iam_instance_profile.arn
}

resource "aws_iam_user_policy_attachment" "vault_ssm_parameters" {
  user       = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.ssm_parameters.arn
}

resource "aws_iam_user" "vault_roles" {
  name = "vault-roles"
  path = "/terraform/"

  tags = {
    ChildProject = "vault"
  }
}

resource "aws_iam_access_key" "vault_roles" {
  user   = aws_iam_user.vault_roles.name
  status = "Active"
}

resource "aws_iam_user_policy_attachment" "vault_roles_iam_role" {
  user       = aws_iam_user.vault_roles.name
  policy_arn = aws_iam_policy.iam_role.arn
}

resource "aws_iam_user_policy_attachment" "vault_roles_s3" {
  user       = aws_iam_user.vault_roles.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
