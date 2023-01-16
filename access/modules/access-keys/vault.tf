resource "aws_iam_user" "vault" {
  name = "vault"
  path = "/terraform/"

  tags = {
    App     = "terraform"
    Project = "vault"
  }
}

resource "aws_iam_user_policy_attachment" "vault" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    aws_iam_policy.dynamodb.arn,
    aws_iam_policy.kms.arn,
    aws_iam_policy.iam_instance_profile.arn,
    aws_iam_policy.ssm_parameters.arn,
  ])

  user       = aws_iam_user.vault.name
  policy_arn = each.value
}

resource "aws_iam_access_key" "vault" {
  user   = aws_iam_user.vault.name
  status = "Active"
}
