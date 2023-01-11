resource "tls_private_key" "ssl" {
  algorithm = "RSA"
}

resource "tls_cert_request" "vault" {
  private_key_pem = tls_private_key.ssl.private_key_pem

  subject {
    common_name = local.domain
  }
}

resource "cloudflare_origin_ca_certificate" "vault" {
  csr          = tls_cert_request.vault.cert_request_pem
  hostnames    = [local.domain]
  request_type = "origin-rsa"

  requested_validity   = 365 * 3
  min_days_for_renewal = 90
}

resource "aws_ssm_parameter" "private_key" {
  name        = "/vault/cloudflare/private-key"
  description = "The private key for the Cloudflare origin CA certificate"

  type  = "SecureString"
  value = tls_private_key.ssl.private_key_pem
}

resource "aws_ssm_parameter" "certificate" {
  name        = "/vault/cloudflare/certificate"
  description = "The Cloudflare origin CA certificate"

  type  = "SecureString"
  value = cloudflare_origin_ca_certificate.vault.certificate
}
