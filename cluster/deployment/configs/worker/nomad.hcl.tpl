datacenter = "${datacenter}"
region = "${region}"

data_dir = "/opt/nomad/data"

bind_addr = "0.0.0.0"

advertise {
  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth1\" }}"
  serf = "{{ GetInterfaceIP \"eth1\" }}"
}

client {
  enabled = true
}

consul {
  address = "127.0.0.1:8500"
  grpc_address = "127.0.0.1:8502"

  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
