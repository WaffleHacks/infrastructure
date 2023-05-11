resource "aws_iam_user" "api" {
  name = "ApplicationPortalApi"
  path = "/portal/"
}

resource "aws_iam_user_policy" "resumes" {
  name   = "ResumeAccess"
  user   = aws_iam_user.api.name
  policy = data.aws_iam_policy_document.resumes.json
}

resource "aws_iam_access_key" "api" {
  user = aws_iam_user.api.name
}

resource "doppler_secret" "api_aws_user_access_key" {
  project = "application-portal"
  config  = "prd"

  name  = "AWS_ACCESS_KEY_ID"
  value = aws_iam_access_key.api.id
}

resource "doppler_secret" "api_aws_user_secret_key" {
  project = "application-portal"
  config  = "prd"

  name  = "AWS_SECRET_ACCESS_KEY"
  value = aws_iam_access_key.api.secret
}
