# TODO: manage SES identity

data "aws_iam_policy_document" "ses" {
  statement {
    effect  = "Allow"
    actions = ["ses:SendEmail", "ses:SendRawEmail"]
    # TODO: restrict to above resource
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "ses:FromAddress"
      values   = ["*@wafflehacks.org"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["ses:ListEmailIdentities"]
    resources = ["*"]
  }
}
