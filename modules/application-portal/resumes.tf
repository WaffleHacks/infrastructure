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
