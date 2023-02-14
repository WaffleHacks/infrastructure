resource "digitalocean_vpc" "cluster" {
  name        = "cluster"
  description = "The WaffleHacks cluster internal network"

  region = var.region.digitalocean
}

resource "digitalocean_firewall" "storage" {
  name = "cluster-storage"

  tags = ["cluster", "storage"]

  droplet_ids = [module.storage.id]

  # TODO: allow disabling ssh access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Postgres
  inbound_rule {
    protocol    = "tcp"
    port_range  = "5432"
    source_tags = ["cluster"]
  }

  # K3s supervisor and Kubernetes API Server from agents
  inbound_rule {
    protocol    = "tcp"
    port_range  = "6443"
    source_tags = ["agent"]
  }

  # Kubelet metrics
  inbound_rule {
    protocol    = "tcp"
    port_range  = "10250"
    source_tags = ["cluster"]
  }

  # Flannel VXLAN
  inbound_rule {
    protocol    = "udp"
    port_range  = "8472"
    source_tags = ["cluster"]
  }


  # Allow traffic from the VPC to NodePorts
  # Temporary fix until https://github.com/digitalocean/digitalocean-cloud-controller-manager/pull/588 is merged
  inbound_rule {
    protocol         = "tcp"
    port_range       = "30000-32767"
    source_addresses = [digitalocean_vpc.cluster.ip_range]
  }

  dynamic "outbound_rule" {
    for_each = ["tcp", "udp"]
    content {
      protocol              = outbound_rule.value
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
}

resource "digitalocean_firewall" "agent" {
  name = "cluster-agent"

  droplet_ids = [for droplet in module.agent : droplet.id]

  # TODO: allow disabling ssh access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Kubelet metrics
  inbound_rule {
    protocol    = "tcp"
    port_range  = "10250"
    source_tags = ["cluster"]
  }

  # Flannel VXLAN
  inbound_rule {
    protocol    = "udp"
    port_range  = "8472"
    source_tags = ["cluster"]
  }

  # Allow traffic from the VPC to NodePorts
  # Temporary fix until https://github.com/digitalocean/digitalocean-cloud-controller-manager/pull/588 is merged
  inbound_rule {
    protocol         = "tcp"
    port_range       = "30000-32767"
    source_addresses = [digitalocean_vpc.cluster.ip_range]
  }

  dynamic "outbound_rule" {
    for_each = ["tcp", "udp"]
    content {
      protocol              = outbound_rule.value
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
}
