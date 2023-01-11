resource "aws_kms_key" "unseal" {
  description = "The key for handling Vault auto-unseal"

  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 14
}

resource "aws_dynamodb_table" "storage" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "Path"
  range_key = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }
}
