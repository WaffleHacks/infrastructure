resource "aws_ses_domain_identity" "domain" {
  domain = "wafflehacks.org"
}

# TODO: manage verification, dkim and configuration set

data "aws_iam_policy_document" "ses" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "ses:FromAddress"
      values   = ["*@${aws_ses_domain_identity.domain.domain}"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["ses:ListEmailIdentities"]
    resources = ["*"]
  }
}
