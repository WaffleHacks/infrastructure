resource "digitalocean_project" "project" {
  name = "Production"

  purpose     = "Web Application"
  environment = "Production"
}

resource "digitalocean_project_resources" "storage" {
  project = digitalocean_project.project.id

  resources = [module.storage.urn]
}

resource "digitalocean_project_resources" "agent" {
  project = digitalocean_project.project.id

  resources = [for agent in module.agent : agent.urn]
}
