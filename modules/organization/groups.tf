# data "aws_identitystore_group" "operations" {
#   identity_store_id = local.identity_store_id

#   alternate_identifier {
#     unique_attribute {
#       attribute_path  = "DisplayName"
#       attribute_value = "Operations"
#     }
#   }
# }

# data "aws_identitystore_group" "people_communications" {
#   identity_store_id = local.identity_store_id

#   alternate_identifier {
#     unique_attribute {
#       attribute_path  = "DisplayName"
#       attribute_value = "People & Communications"
#     }
#   }
# }

# data "aws_identitystore_group" "technology" {
#   identity_store_id = local.identity_store_id

#   alternate_identifier {
#     unique_attribute {
#       attribute_path  = "DisplayName"
#       attribute_value = "Technology"
#     }
#   }
# }

# data "aws_identitystore_group" "administrators" {
#   identity_store_id = local.identity_store_id

#   alternate_identifier {
#     unique_attribute {
#       attribute_path  = "DisplayName"
#       attribute_value = "Administrators"
#     }
#   }
# }
