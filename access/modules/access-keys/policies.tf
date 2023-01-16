data "aws_iam_policy_document" "dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateTable",
      "dynamodb:UpdateTimeToLive",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "dynamodb" {
  name        = "TerraformDynamoDBPolicy"
  path        = "/terraform/"
  description = "Allows Terraform to manage DynamoDB resources"

  policy = data.aws_iam_policy_document.dynamodb.json
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:DescribeKey",
      "kms:DisableKey",
      "kms:DisableKeyRotation",
      "kms:EnableKey",
      "kms:EnableKeyRotation",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:UpdateKeyDescription",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kms" {
  name        = "TerraformKMSPolicy"
  path        = "/terraform/"
  description = "Allows Terraform to manage KMS resources"

  policy = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "iam_instance_profile" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreateRole",
      "iam:DeleteInstanceProfile",
      "iam:DeleteRole",
      "iam:DeleteRolePermissionsBoundary",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetInstanceProfile",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:TagRole",
      "iam:UntagInstanceProfile",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_instance_profile" {
  name        = "TerraformIAMInstanceProfilePolicy"
  path        = "/terraform/"
  description = "Allows Terraform to manage IAM instance profile resources"

  policy = data.aws_iam_policy_document.iam_instance_profile.json
}

data "aws_iam_policy_document" "ssm_parameters" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DeleteParameter",
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:PutParameter",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:AddTagsToResource",
      "ssm:ListTagsForResource",
      "ssm:RemoveTagsFromResource",
    ]
    resources = ["arn:aws:ssm:*:*:parameter/*"]
  }
}

resource "aws_iam_policy" "ssm_parameters" {
  name        = "TerraformSSMParametersPolicy"
  path        = "/terraform/"
  description = "Allows Terraform to manage SSM parameters"

  policy = data.aws_iam_policy_document.ssm_parameters.json
}
