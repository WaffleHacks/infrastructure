data "digitalocean_ssh_key" "cluster" {
  name = var.ssh_key
}

module "storage" {
  source = "./modules/storage"

  region = var.region
  type   = "g6-standard-2"

  ssh_key = data.digitalocean_ssh_key.cluster.id

  vpc = {
    id   = digitalocean_vpc.cluster.id
    cidr = digitalocean_vpc.cluster.ip_range
  }

  vault_address = var.vault_address
  backup_bucket = var.storage_backup_bucket
}
