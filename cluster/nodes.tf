data "digitalocean_ssh_key" "cluster" {
  name = var.ssh_key
}

module "storage" {
  source = "./modules/storage"

  region  = var.region
  ssh_key = data.digitalocean_ssh_key.cluster.id

  vpc = {
    id   = digitalocean_vpc.cluster.id
    cidr = digitalocean_vpc.cluster.ip_range
  }

  vault_address = var.vault_address
  backup_bucket = var.storage_backup_bucket
}

module "agent" {
  source = "./modules/agent"

  count = 2

  region  = var.region.digitalocean
  vpc_id  = digitalocean_vpc.cluster.id
  ssh_key = data.digitalocean_ssh_key.cluster.id

  join_token = module.storage.join_token
  master_ip  = module.storage.internal_address
}
