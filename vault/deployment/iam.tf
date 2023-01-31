data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "instance" {
  statement {
    sid = "OriginCACertificate"

    effect  = "Allow"
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.certificate.arn,
      aws_ssm_parameter.private_key.arn,
    ]
  }

  # From https://developer.hashicorp.com/vault/docs/configuration/seal/awskms#authentication
  statement {
    sid = "VaultKMSAutoUnseal"

    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = [aws_kms_key.unseal.arn]
  }

  # From https://developer.hashicorp.com/vault/docs/configuration/storage/dynamodb#required-aws-permissions
  statement {
    sid = "VaultDynamoDBStorage"

    effect = "Allow"
    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable",
    ]
    resources = [aws_dynamodb_table.storage.arn]
  }

  statement {
    sid = "VaultAWSSecretEngine"

    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Vault*"]
  }
}

resource "aws_iam_role" "instance" {
  name               = "vault-instance-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "instance" {
  name   = "vault-instance-role-policy"
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.instance.json
}

resource "aws_iam_instance_profile" "instance" {
  name = "vault-instance-profile"
  role = aws_iam_role.instance.name
}
