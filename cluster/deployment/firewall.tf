locals {
  controller_ips = [for instance in linode_instance.controller : "${instance.private_ip_address}/32"]
  worker_ips     = [for instance in linode_instance.worker : "${instance.private_ip_address}/32"]
  all_ips        = flatten([local.controller_ips, local.worker_ips])

  serf_ports = {
    "consul-serf-lan" = "8301"
    "consul-serf-wan" = "8302"
    "nomad-serf"      = "4648"
  }
  shared_ports = {
    "consul-http" = "8500"
    "consul-rpc"  = "8502"
    "nomad-http"  = "4646"
    "nomad-rpc"   = "4647"
  }
}

resource "linode_firewall" "controller" {
  label = "controller-firewall"

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  dynamic "inbound" {
    for_each = local.shared_ports

    content {
      label    = inbound.key
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = inbound.value
      ipv4     = local.all_ips
    }
  }

  # Consul server
  inbound {
    label    = "consul-server"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8300"
    ipv4     = local.controller_ips
  }

  # Serf TCP
  dynamic "inbound" {
    for_each = local.serf_ports

    content {
      label    = inbound.key
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = inbound.value
      ipv4     = local.controller_ips
    }
  }

  # Serf UDP
  dynamic "inbound" {
    for_each = local.serf_ports

    content {
      label    = inbound.key
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = inbound.value
      ipv4     = local.controller_ips
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

resource "linode_firewall_device" "controller" {
  count = var.controller_count

  firewall_id = linode_firewall.controller.id
  entity_id   = linode_instance.controller[count.index].id
}

resource "linode_firewall" "worker" {
  label = "worker-firewall"

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  dynamic "inbound" {
    for_each = local.shared_ports

    content {
      label    = inbound.key
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = inbound.value
      ipv4     = local.all_ips
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

resource "linode_firewall_device" "worker" {
  count = var.worker_count

  firewall_id = linode_firewall.worker.id
  entity_id   = linode_instance.worker[count.index].id
}
