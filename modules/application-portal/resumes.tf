resource "aws_s3_bucket" "resumes" {
  bucket = "wafflehacks-application-portal-resumes"
}

resource "aws_s3_bucket_ownership_controls" "resumes" {
  bucket = aws_s3_bucket.resumes.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "resumes" {
  depends_on = [aws_s3_bucket_ownership_controls.resumes]

  bucket = aws_s3_bucket.resumes.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "resumes" {
  bucket = aws_s3_bucket.resumes.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://apply.wafflehacks.org", "https://localhost.localdomain:3000"]
    expose_headers  = ["x-amz-request-id"]
    max_age_seconds = 3600
  }
}

data "aws_iam_policy_document" "resumes" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.resumes.arn}/*"]
  }
}

resource "doppler_secret" "api_resume_bucket" {
  project = "application-portal"
  config  = "prd"

  name  = "RESUME_BUCKET"
  value = aws_s3_bucket.resumes.bucket
}
