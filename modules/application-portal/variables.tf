variable "github_actions_provider" {
  type        = string
  description = "The ARN of the GitHub federated identity provider to use"
}

variable "github_actions_provider_google" {
  type = object({
    id       = string
    provider = string
  })
  description = "The ID of the GitHub federated identity provider to use"
}
