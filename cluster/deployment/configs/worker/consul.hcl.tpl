datacenter = "${datacenter}"
data_dir = "/opt/consul"

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

log_level = "INFO"

retry_join = ["provider=linode region=${datacenter} tag_name=cluster address_type=private_v4"]

connect {
  enabled = true
}

ports {
  grpc = 8502
}
