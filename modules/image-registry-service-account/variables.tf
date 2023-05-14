variable "github" {
  type = object({
    name  = string
    owner = string
  })
  description = "The GitHub source repository owner and name"
}

variable "repository" {
  type = object({
    project  = string
    location = string
    name     = string
  })
  description = "The Artifact Registry repository to assign the service account to"
}

variable "workload_identity_pool_id" {
  type        = string
  description = "The IAM Workload Identity pool ID"
}
