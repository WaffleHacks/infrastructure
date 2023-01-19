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
