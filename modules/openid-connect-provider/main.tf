terraform {
  required_version = ">= 1.4.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
  }
}

resource "aws_iam_openid_connect_provider" "provider" {
  client_id_list  = [var.audience]
  thumbprint_list = [for certificate in data.tls_certificate.provider.certificates : certificate.sha1_fingerprint]
  url             = var.url
}
