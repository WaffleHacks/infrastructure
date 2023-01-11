resource "aws_vpc" "main" {
  cidr_block = "172.24.0.0/20"

  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "vault-vpc"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vault-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  cidr_block      = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0)

  assign_ipv6_address_on_creation     = true
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "resource-name"

  tags = {
    Name = "vault-subnet-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.public.id
  }

  tags = {
    Name = "vault-rtb-public"
  }
}

resource "aws_route_table_association" "subnet" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

data "cloudflare_ip_ranges" "cloudflare" {}

resource "aws_ec2_managed_prefix_list" "cloudflare_ipv4" {
  name           = "Cloudflare IPv4"
  address_family = "IPv4"
  max_entries    = length(data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks)

  dynamic "entry" {
    for_each = data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks
    content {
      cidr = entry.value
    }
  }
}

resource "aws_ec2_managed_prefix_list" "cloudflare_ipv6" {
  name           = "Cloudflare IPv6"
  address_family = "IPv6"
  max_entries    = length(data.cloudflare_ip_ranges.cloudflare.ipv6_cidr_blocks)

  dynamic "entry" {
    for_each = data.cloudflare_ip_ranges.cloudflare.ipv6_cidr_blocks
    content {
      cidr = entry.value
    }
  }
}

resource "aws_security_group" "vault" {
  name        = "vault-security-group"
  description = "Allow traffic from the internet to the Vault server"
  vpc_id      = aws_vpc.main.id

  # HTTP from CloudFront
  ingress {
    from_port = 8200
    to_port   = 8200
    protocol  = "tcp"

    prefix_list_ids = [
      aws_ec2_managed_prefix_list.cloudflare_ipv4.id,
      aws_ec2_managed_prefix_list.cloudflare_ipv6.id,
    ]
  }

  # Optionally enable ssh
  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []

    content {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"

      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
