terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"

      configuration_aliases = [aws.us_east_1]
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.2.2"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.64.0"
    }
  }
}
