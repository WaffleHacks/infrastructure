#!/usr/bin/env bash
#
#
#<UDF name="consul_version" label="Consul version" />
# CONSUL_VERSION=
#
#<UDF name="consul_template_version" label="Consul template version" />
# CONSUL_TEMPLATE_VERSION=
#
#<UDF name="nomad_version" label="Nomad version" />
# NOMAD_VERSION=

exec > >(tee -i /var/log/stackscript.log)

set -ex

source <ssinclude StackScriptID="${shared_stackscript_id}">

system_setup $CONSUL_VERSION $CONSUL_TEMPLATE_VERSION $NOMAD_VERSION

# Configure Consul
cat <<EOF > /etc/consul.d/consul.hcl
datacenter = "${region}"
data_dir = "/opt/consul"

server = true

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

log_level = "INFO"

bootstrap_expect = ${bootstrap_expect}
retry_join = ["provider=linode region=${region} tag_name=cluster address_type=private_v4"]

connect {
  enabled = true
}

ui_config {
  enabled = true
}
EOF

cat <<EOF > /etc/consul.d/consul.env
LINODE_TOKEN=${auto_discovery_token}
EOF

systemctl enable consul.service
systemctl start consul.service

# Wait for consul to start
printf "Waiting 30s for Consul to start..."
sleep 30
