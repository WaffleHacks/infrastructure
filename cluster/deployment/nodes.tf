locals {
  image = "linode/debian11"

  stackscript_data = {
    consul_version          = "1.14.3-1"
    consul_template_version = "0.30.0-1"
    nomad_version           = "1.4.3-1"
    cni_version             = "1.2.0"
    traefik_version         = "2.9.6"
  }
}

resource "linode_stackscript" "controller" {
  label       = "cluster-controller"
  description = "Sets up a controller node"

  script = templatefile("${path.module}/scripts/setup.sh", {
    auto_discovery_token = var.linode_auto_discovery_token
    cloudflare_api_token = var.cloudflare_letsencrypt_token

    letsencrypt_email = var.letsencrypt_email

    post_setup = ""
    consul_config = templatefile("${path.module}/configs/controller/consul.hcl.tpl", {
      datacenter       = var.region
      bootstrap_expect = var.controller_count
    })
    nomad_config = templatefile("${path.module}/configs/controller/nomad.hcl.tpl", {
      datacenter       = var.region
      region           = data.linode_region.current.country
      bootstrap_expect = var.controller_count
    })
  })

  images = [local.image]
}

resource "random_password" "controller" {
  count = var.controller_count

  length = 64

  lower   = true
  upper   = true
  numeric = true
  special = true

  min_lower   = 4
  min_upper   = 4
  min_numeric = 4
  min_special = 4
}

resource "linode_instance" "controller" {
  count = var.controller_count

  label = "controller-${count.index}"
  image = local.image

  type   = var.controller_type
  region = var.region

  root_pass = random_password.controller[count.index].result

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

  script = templatefile("${path.module}/scripts/setup.sh", {
    auto_discovery_token = var.linode_auto_discovery_token
    cloudflare_api_token = var.cloudflare_letsencrypt_token

    letsencrypt_email = var.letsencrypt_email

    # TODO: add these
    post_setup    = ""
    consul_config = ""
    nomad_config  = ""
  })

  images = [local.image]
}

resource "random_password" "worker" {
  count = var.worker_count

  length = 64

  lower   = true
  upper   = true
  numeric = true
  special = true

  min_lower   = 4
  min_upper   = 4
  min_numeric = 4
  min_special = 4
}

resource "linode_instance" "worker" {
  count = var.worker_count

  label = "worker-${count.index}"
  image = local.image

  type   = var.worker_type
  region = var.region

  root_pass = random_password.worker[count.index].result

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

