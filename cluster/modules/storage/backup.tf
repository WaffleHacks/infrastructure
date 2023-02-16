resource "aws_s3_bucket" "backup" {
  bucket = var.backup_bucket

  tags = {
    Name = var.backup_bucket
  }
}

resource "aws_s3_bucket_acl" "backup" {
  bucket = aws_s3_bucket.backup.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id = "wal"

    filter {
      prefix = "wal/"
    }

    expiration {
      days = 2
    }

    status = "Enabled"
  }

  rule {
    id = "full"

    filter {
      prefix = "full/"
    }

    expiration {
      days = 7
    }

    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "backup" {
  statement {
    sid = "ListBucket"

    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.backup.arn]
  }

  statement {
    sid = "ReadWrite"

    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.backup.arn}/*", ]
  }
}

resource "aws_iam_role" "backup" {
  name = "ClusterStorageBackup"
  path = "/vault/"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "backup" {
  name   = "ClusterStorageBackupPolicy"
  role   = aws_iam_role.backup.id
  policy = data.aws_iam_policy_document.backup.json
}

resource "vault_aws_secret_backend_role" "backup" {
  backend = "aws"

  name            = "cluster-storage-backup"
  credential_type = "assumed_role"

  role_arns = [
    aws_iam_role.backup.arn
  ]
}

resource "vault_approle_auth_backend_role" "backup" {
  backend   = "approle"
  role_name = "cluster-storage-backup"

  token_ttl      = 60 * 5
  token_max_ttl  = 60 * 15
  token_policies = ["aws-credentials"]
}

resource "vault_approle_auth_backend_role_secret_id" "backup" {
  backend   = "approle"
  role_name = vault_approle_auth_backend_role.backup.role_name

  metadata = jsonencode({
    "aws_role" = vault_aws_secret_backend_role.backup.name
  })
}
