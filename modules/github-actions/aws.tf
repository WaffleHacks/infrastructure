data "http" "openid_configuration" {
  url = "${local.url}/.well-known/openid-configuration"

  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Invalid status code"
    }
  }
}

locals {
  openid_configuration = jsondecode(data.http.openid_configuration.response_body)
  jwks_uri_parts       = split("/", local.openid_configuration.jwks_uri)
  certificate_url      = join("/", slice(local.jwks_uri_parts, 0, 3))
}

data "tls_certificate" "provider" {
  url = local.certificate_url
}

resource "aws_iam_openid_connect_provider" "github" {
  url = local.url

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [for certificate in data.tls_certificate.provider.certificates : certificate.sha1_fingerprint]
}
