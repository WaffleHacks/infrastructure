variable "url" {
  type        = string
  description = "The URL of the identity provider. Corresponds to the iss claim"
}

variable "audience" {
  type        = string
  description = "The audience of the identity provider for identifying the application. Sent as the client_id parameter on OAuth requests."
}
