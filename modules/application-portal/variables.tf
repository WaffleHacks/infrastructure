variable "github_actions_provider" {
  type = object({
    id       = string
    provider = string
  })
  description = "The ID of the GitHub federated identity provider to use"
}
