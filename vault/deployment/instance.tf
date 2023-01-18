data "hcp_packer_image" "vault" {
  bucket_name = var.packer_bucket
  channel     = var.packer_channel

  cloud_provider = "aws"
  region         = var.region
}

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "ssh" {
  key_name_prefix = "vault-"
  public_key      = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "vault" {
  ami           = data.hcp_packer_image.vault.cloud_image_id
  instance_type = "t4g.small"

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.vault.id]

  key_name             = aws_key_pair.ssh.key_name
  iam_instance_profile = aws_iam_instance_profile.instance.name

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    # Require IMDSv2
    http_endpoint = "enabled"
    http_tokens   = "required"

    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = 10

    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/user-data.sh.tpl", {
    domain = local.domain

    region  = var.region
    kms_key = aws_kms_key.unseal.key_id

    dynamodb_table = aws_dynamodb_table.storage.name
  })
  user_data_replace_on_change = true
}

resource "local_sensitive_file" "ssh_key" {
  count = var.enable_ssh ? 1 : 0

  filename = "${path.module}/instance.pem"
  content  = tls_private_key.ssh.private_key_openssh

  file_permission = "0600"
}
