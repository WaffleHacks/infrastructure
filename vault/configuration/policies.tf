locals {
  policy_files = fileset(path.module, "policies/*.hcl")
  policy_names = [for file in local.policy_files : trimsuffix(basename(file), ".hcl")]

  policies = zipmap(local.policy_names, tolist(local.policy_files))
}

resource "vault_policy" "policies" {
  for_each = local.policies

  name   = each.key
  policy = file(each.value)
}

resource "vault_policy" "aws_credentials" {
  name = "aws-credentials"
  policy = templatefile("${path.module}/policies/templated/aws-credentials.hcl", {
    approle_mount = data.vault_auth_backend.approle.accessor
  })
}
