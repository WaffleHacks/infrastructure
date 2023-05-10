module "application_portal_image_repository" {
  source = "./modules/image-repository"
  providers = {
    aws = aws.us_east_1
  }

  name            = "application-portal"
  subrepositories = ["api", "mjml", "tasks"]
  description     = "A component of the WaffleHacks application portal."

  github_repository       = "WaffleHacks/application-portal"
  github_actions_provider = module.github_actions.arn
}
