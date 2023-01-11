packer {
  required_plugins {
    amazon = {
      version = "~> 1.1.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type        = string
  description = "The region to build the image in."
}

variable "bucket_name" {
  type        = string
  description = "The slug of the HCP Packer Registry image bucket to push to"
}

locals {
  vault_version = "1.12.2-1"

  architecture = "arm64"
  os           = "debian-11"
  timestamp    = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "vault" {
  ami_name      = "vault-${local.timestamp}"
  instance_type = "t4g.small"
  region        = var.region

  source_ami_filter {
    most_recent = true
    owners      = ["amazon"]

    filters = {
      name                = "${local.os}-${local.architecture}-*"
      architecture        = local.architecture
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
  }

  run_volume_tags = {
    iteration_id = packer.iterationID
  }

  tags = {
    iteration_id = packer.iterationID
    os           = local.os
    source       = "{{ .SourceAMIName }}"
    version      = local.vault_version
  }

  ssh_username = "admin"
}

build {
  name = "vault"
  sources = [
    "source.amazon-ebs.vault"
  ]

  # Perform initial OS configuration
  provisioner "shell" {
    script = "scripts/setup.sh"
  }

  # Install Vault
  provisioner "shell" {
    environment_vars = [
      "VAULT_VERSION=${local.vault_version}"
    ]
    script = "scripts/install.sh"
  }

  # Update Cloudflare origin certificate weekly
  provisioner "file" {
    destination = "/tmp/update-origin-certificate.sh"
    source      = "scripts/update-origin-certificate.sh"
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/update-origin-certificate.sh /etc/cron.weekly/update-origin-certificate.sh",
      "sudo chmod +x /etc/cron.weekly/update-origin-certificate.sh",
    ]
  }

  hcp_packer_registry {
    bucket_name = var.bucket_name
    description = "An image pre-configured to launch HashiCorp Vault backed by AWS DynamoDB with AWS KMS for auto-unseal."

    bucket_labels = {
      "os"   = "linux"
      "arch" = local.architecture
    }

    build_labels = {
      "version" = local.vault_version
      "os"      = local.os
      "at"      = timestamp()
    }
  }
}
