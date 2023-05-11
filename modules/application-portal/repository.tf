module "image_repository" {
  source = "../image-repository"
  providers = {
    aws = aws.us_east_1
  }

  name            = "application-portal"
  subrepositories = ["api", "mjml", "tasks"]
  description     = "A component of the WaffleHacks application portal."

  github_repository       = "WaffleHacks/application-portal"
  github_actions_provider = var.github_actions_provider
}

resource "doppler_secret" "github_publish_role" {
  project = "application-portal"
  config  = "gha"

  name  = "AWS_ROLE"
  value = module.image_repository.role_arn
}
