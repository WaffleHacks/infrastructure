resource "digitalocean_tag" "cluster" {
  name = "cluster"
}

resource "digitalocean_tag" "storage" {
  name = "storage"
}

resource "digitalocean_tag" "agent" {
  name = "agent"
}
