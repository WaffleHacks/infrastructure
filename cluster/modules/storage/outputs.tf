output "id" {
  value       = digitalocean_droplet.instance.id
  description = "The ID of the created storage node"
}

output "join_token" {
  value       = random_password.join_token.result
  description = "The token to use for joining the cluster"
}