variable "aws" {
  type = object({
    region = string
  })
  description = "The AWS provider configuration"
}

variable "doppler_token" {
  type        = string
  description = "The Doppler personal token to authenticate with"
}

variable "google" {
  type = object({
    project = string
    region  = string
  })
  description = "The Google Cloud provider configuration"
}
