# Infrastructure

Automated configuration and setup for the servers and associated services powering WaffleHacks.

All configuration is managed by HashiCorp [Terraform](https://terraform.io) and [Packer](https://packer.io).


### Order of Operations

To start from scratch, projects must be initialized in the following order:
- access
- vault/image
- vault/deployment
- vault/configuration
- cluster
