resource "aws_iam_user" "mailer" {
  name = "Mailer"
}

resource "aws_iam_user_policy" "ses" {
  name   = "SESAccess"
  user   = aws_iam_user.mailer.name
  policy = data.aws_iam_policy_document.ses.json
}

resource "aws_iam_access_key" "mailer" {
  user = aws_iam_user.mailer.name
}

resource "doppler_secret" "aws_user_access_key" {
  project = "mailer"
  config  = "prd"

  name  = "MAILER_PROVIDER_SES_ACCESS_KEY"
  value = aws_iam_access_key.mailer.id
}

resource "doppler_secret" "aws_user_secret_key" {
  project = "mailer"
  config  = "prd"

  name  = "MAILER_PROVIDER_SES_SECRET_KEY"
  value = aws_iam_access_key.mailer.secret
}
