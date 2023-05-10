module "mailer_image_repository" {
  source = "./modules/image-repository"
  providers = {
    aws = aws.us_east_1
  }

  name        = "mailer"
  description = "A generic email interface for all WaffleHacks services."

  github_repository       = "WaffleHacks/mailer"
  github_actions_provider = module.github_actions.arn
}
