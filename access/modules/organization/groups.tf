resource "aws_identitystore_group" "operations" {
  identity_store_id = local.identity_store_id

  display_name = "Operations"
  description  = "The operations team"
}

resource "aws_identitystore_group" "people_communications" {
  identity_store_id = local.identity_store_id

  display_name = "People-Communications"
  description  = "The people & communications team"
}

resource "aws_identitystore_group" "technology" {
  identity_store_id = local.identity_store_id

  display_name = "Technology"
  description  = "The technology team"
}

resource "aws_identitystore_group" "administrators" {
  identity_store_id = local.identity_store_id

  display_name = "Administrators"
  description  = "Has full admin access to all organization accounts"
}
