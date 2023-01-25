locals {
  controller_private_ips = [for instance in linode_instance.controller : "${instance.private_ip_address}/32"]
  worker_private_ips     = [for instance in linode_instance.worker : "${instance.private_ip_address}/32"]
  node_private_ips       = flatten([local.controller_private_ips, local.worker_private_ips])

  public_ports = {
    "http"  = 80
    "https" = 443
  }
  internal_tcp_ports = {
    "consul-http"     = 8500
    "consul-rpc"      = 8502
    "nomad-http"      = 4646
    "nomad-rpc"       = 4647
    "consul-server"   = 8300
    "consul-serf-lan" = 8301
    "consul-serf-wan" = 8302
    "nomad-serf"      = 4648
  }
  internal_udp_ports = {
    "consul-serf-lan" = 8301
    "consul-serf-wan" = 8302
    "nomad-serf"      = 4648
  }
}

data "cloudflare_ip_ranges" "all" {}

resource "linode_firewall" "node" {
  label = "cluster-firewall"

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  dynamic "inbound" {
    for_each = local.public_ports

    content {
      label    = inbound.key
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = inbound.value
      ipv4     = data.cloudflare_ip_ranges.all.ipv4_cidr_blocks
      ipv6     = data.cloudflare_ip_ranges.all.ipv6_cidr_blocks
    }
  }

  dynamic "inbound" {
    for_each = local.internal_tcp_ports

    content {
      label    = inbound.key
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = inbound.value
      ipv4     = local.node_private_ips
    }
  }

  dynamic "inbound" {
    for_each = local.internal_udp_ports

    content {
      label    = inbound.key
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = inbound.value
      ipv4     = local.node_private_ips
    }
  }

  # SSH
  dynamic "inbound" {
    for_each = var.enable_ssh ? [1] : []

    content {
      label    = "ssh"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = "22"
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }
}

resource "time_sleep" "node_firewall" {
  depends_on = [linode_firewall.node]

  create_duration = "5s"
  triggers = {
    controller_ips = join(" ", local.controller_private_ips)
    worker_ips     = join(" ", local.worker_private_ips)
  }
}

resource "linode_firewall_device" "controller" {
  count      = var.controller_count
  depends_on = [time_sleep.node_firewall]

  firewall_id = linode_firewall.node.id
  entity_id   = linode_instance.controller[count.index].id
}

resource "linode_firewall_device" "worker" {
  count      = var.worker_count
  depends_on = [time_sleep.node_firewall]

  firewall_id = linode_firewall.node.id
  entity_id   = linode_instance.worker[count.index].id
}
