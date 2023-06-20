variable "github" {
  type = object({
    name  = string
    owner = string
  })
  description = "The GitHub source repository owner and name"
}

variable "workload_identity_pool_id" {
  type        = string
  description = "The IAM Workload Identity pool ID"
}
