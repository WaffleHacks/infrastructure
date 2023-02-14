output "id" {
  value       = digitalocean_droplet.instance.id
  description = "The ID of the created agent node"
}

output "urn" {
  value       = digitalocean_droplet.instance.urn
  description = "The URN of the created agent node"
}
