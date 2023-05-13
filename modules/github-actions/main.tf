terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.64.0"
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

locals {
  url = "https://token.actions.githubusercontent.com"
}
