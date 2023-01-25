locals {
  consul_fqdn = "${var.consul_subdomain}.${var.domain}"
  nomad_fqdn  = "${var.nomad_subdomain}.${var.domain}"

  node_ipv4 = { for i, instance in linode_instance.controller : "controller-${i}" => instance.ip_address }
  node_ipv6 = { for i, instance in linode_instance.controller : "controller-${i}" => trimsuffix(instance.ipv6, "/128") }
}

data "cloudflare_zone" "current" {
  name = var.domain
}

resource "cloudflare_record" "consul_ipv4" {
  for_each = local.node_ipv4

  zone_id = data.cloudflare_zone.current.id

  name  = var.consul_subdomain
  type  = "A"
  value = each.value

  proxied = true
}

resource "cloudflare_record" "consul_ipv6" {
  for_each = local.node_ipv6

  zone_id = data.cloudflare_zone.current.id

  name  = var.consul_subdomain
  type  = "AAAA"
  value = each.value

  proxied = true
}

resource "cloudflare_record" "nomad_ipv4" {
  for_each = local.node_ipv4

  zone_id = data.cloudflare_zone.current.id

  name  = var.nomad_subdomain
  type  = "A"
  value = each.value

  proxied = true
}

resource "cloudflare_record" "nomad_ipv6" {
  for_each = local.node_ipv6

  zone_id = data.cloudflare_zone.current.id

  name  = var.nomad_subdomain
  type  = "AAAA"
  value = each.value

  proxied = true
}
