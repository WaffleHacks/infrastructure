resource "vault_mount" "passwords" {
  path = "passwords"
  type = "kv-v2"

  description = "Shared passwords for various services"
}

resource "vault_kv_secret_backend_v2" "passwords" {
  mount = vault_mount.passwords.path

  max_versions = 0 # unlimited
  cas_required = true
}

resource "vault_mount" "aws" {
  path = "aws"
  type = "aws"

  description = "Generate AWS credentials on the fly"
}

resource "vault_aws_secret_backend" "aws" {
  path = vault_mount.aws.path

  username_template = <<EOF
  {{ if (eq .Type "STS") }}
    {{ printf "vault-%s-%s" (unix_time) (random 20) | truncate 32 }}
  {{ else }}
      {{ printf "vault-%s-%s-%s" (printf "%s-%s" (.DisplayName) (.PolicyName) | truncate 42) (unix_time) (random 20) | truncate 64 }}
  {{ end }}
    EOF
}
