locals {
  stackscript_data = {
    consul_version          = "1.14.3-1"
    consul_template_version = "0.30.0-1"
    nomad_version           = "1.4.3-1"
  }
}

resource "linode_stackscript" "shared" {
  label       = "shared"
  description = "Shared functions between controller and worker nodes"

  script = file("${path.module}/scripts/shared.sh")

  images = [local.image]
}

resource "linode_stackscript" "controller" {
  label       = "cluster-controller"
  description = "Sets up a controller node"

  script = templatefile("${path.module}/scripts/controller.sh", {
    datacenter            = var.region
    region                = data.linode_region.current.country
    shared_stackscript_id = linode_stackscript.shared.id

    auto_discovery_token = var.linode_auto_discovery_token
    bootstrap_expect     = var.controller_count
  })

  images = [local.image]
}

resource "linode_instance" "controller" {
  count = var.controller_count

  label = "controller-${count.index}"
  image = local.image

  type   = var.controller_type
  region = var.region

  private_ip       = true
  backups_enabled  = false
  watchdog_enabled = true

  group = "controllers"
  tags  = ["cluster", "controller"]

  stackscript_id   = linode_stackscript.controller.id
  stackscript_data = local.stackscript_data

  interface {
    purpose = "public"
  }

  interface {
    purpose = "vlan"
    label   = "cluster-internal"
  }
}

resource "linode_stackscript" "worker" {
  label       = "cluster-worker"
  description = "Sets up a worker node"

  script = templatefile("${path.module}/scripts/worker.sh", {
    shared_stackscript_id = linode_stackscript.shared.id
  })

  images = [local.image]
}

resource "linode_instance" "worker" {
  count = var.worker_count

  label = "worker-${count.index}"
  image = local.image

  type   = var.worker_type
  region = var.region

  private_ip       = true
  backups_enabled  = false
  watchdog_enabled = true

  group = "workers"
  tags  = ["cluster", "worker"]

  stackscript_id   = linode_stackscript.worker.id
  stackscript_data = local.stackscript_data

  interface {
    purpose = "public"
  }

  interface {
    purpose = "vlan"
    label   = "cluster-internal"
  }
}

