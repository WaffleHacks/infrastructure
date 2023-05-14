variable "github_actions_provider_aws" {
  type        = string
  description = "The ARN of the GitHub federated identity provider to use"
}

variable "image_repository" {
  type = object({
    project  = string
    location = string
    name     = string
  })
  description = "The GCP Artifact Registry repository to use"
}

variable "github_actions_provider" {
  type = object({
    id       = string
    provider = string
  })
  description = "The ID of the GitHub federated identity provider to use"
}
