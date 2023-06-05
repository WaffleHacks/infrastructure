resource "aws_s3_bucket" "exports" {
  bucket = "wafflehacks-application-portal-exports"
}

resource "aws_s3_bucket_ownership_controls" "exports" {
  bucket = aws_s3_bucket.exports.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "exports" {
  depends_on = [aws_s3_bucket_ownership_controls.exports]

  bucket = aws_s3_bucket.exports.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "exports" {
  bucket = aws_s3_bucket.exports.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://apply.wafflehacks.org", "https://localhost.localdomain:3000"]
    expose_headers  = ["x-amz-request-id"]
    max_age_seconds = 3600
  }
}

data "aws_iam_policy_document" "exports" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.exports.arn}/*"]
  }
}

resource "doppler_secret" "api_export_bucket" {
  project = "application-portal"
  config  = "prd"

  name  = "EXPORT_BUCKET"
  value = aws_s3_bucket.exports.bucket
}
