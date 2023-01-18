data "cloudflare_zone" "main" {
  name = var.domain
}

locals {
  domain = "${var.subdomain}.${var.domain}"
}

resource "cloudflare_record" "a" {
  zone_id = data.cloudflare_zone.main.id

  name  = var.subdomain
  type  = "A"
  value = aws_instance.vault.public_ip

  proxied = true
  ttl     = 1
}

resource "cloudflare_record" "aaaa" {
  zone_id = data.cloudflare_zone.main.id

  name  = var.subdomain
  type  = "AAAA"
  value = aws_instance.vault.ipv6_addresses[0]

  proxied = true
  ttl     = 1
}

resource "cloudflare_ruleset" "default" {
  zone_id = data.cloudflare_zone.main.id

  name        = "default"
  description = ""

  kind  = "zone"
  phase = "http_request_origin"

  rules {
    action = "route"
    action_parameters {
      origin {
        port = 8200
      }
    }

    expression  = "(http.host eq \"${local.domain}\")"
    description = "Vault Port Redirect"
    enabled     = true
  }
}
