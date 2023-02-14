output "id" {
  value       = digitalocean_droplet.instance.id
  description = "The ID of the created storage node"
}

output "urn" {
  value       = digitalocean_droplet.instance.urn
  description = "The URN of the created storage node"
}

output "internal_address" {
  value       = digitalocean_droplet.instance.ipv4_address_private
  description = "The private IP address of the created storage node"
}

output "join_token" {
  value       = random_password.join_token.result
  description = "The token to use for joining the cluster"
}
