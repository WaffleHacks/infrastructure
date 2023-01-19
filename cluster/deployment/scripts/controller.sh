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
