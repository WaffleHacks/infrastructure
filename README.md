# Infrastructure

Automated configuration and setup for the servers and associated services powering WaffleHacks.

All configuration is managed by HashiCorp [Terraform](https://terraform.io) and [Packer](https://packer.io).


### Permissions

The expected AWS IAM policies are as follows:

- `arn:aws:iam::aws:policy/AWSOrganizationsFullAccess`
- `arn:aws:iam::aws:policy/AWSSSODirectoryAdministrator`
- `arn:aws:iam::aws:policy/AWSSSOMasterAccountAdministrator`
- `arn:aws:iam::aws:policy/IAMFullAccess`
