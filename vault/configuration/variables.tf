variable "address" {
  type        = string
  description = "The address of the Vault instance"
}

variable "auth_path" {
  type        = string
  description = "The path to the authentication method to use"
}

variable "auth_parameters" {
  type        = map(string)
  description = "The parameters to pass to the authentication method"
}
