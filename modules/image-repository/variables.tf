variable "name" {
  type        = string
  description = "The name of the ECR repository"
}

variable "subrepositories" {
  type        = list(string)
  default     = []
  description = "The suffixes of repositories to add to the name"
}

variable "description" {
  type        = string
  default     = null
  description = "A short description for the repository"
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository to allow publishing images from"
}

variable "github_actions_provider" {
  type        = string
  description = "The ARN of the GitHub Actions federated identity provider"
}
