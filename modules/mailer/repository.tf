module "image_repository" {
  source = "../image-repository"
  providers = {
    aws = aws.us_east_1
  }

  name        = "mailer"
  description = "A generic email interface for all WaffleHacks services."

  github_repository       = "WaffleHacks/mailer"
  github_actions_provider = var.github_actions_provider
}

resource "doppler_secret" "github_publish_role" {
  project = "mailer"
  config  = "gha"

  name  = "AWS_ROLE"
  value = module.image_repository.role_arn
}
