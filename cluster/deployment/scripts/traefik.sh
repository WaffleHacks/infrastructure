# Install Traefik
curl -L -o traefik.tar.gz https://github.com/traefik/traefik/releases/download/v2.9.6/traefik_v2.9.6_linux_amd64.tar.gz
tar -xzf traefik.tar.gz
mv traefik /usr/local/bin/traefik
rm traefik.tar.gz

# Configure Traefik
mkdir -p /etc/traefik
cat <<EOF > /etc/traefik/traefik.yaml
experimental:
  http3: true

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
    http3: {}

  https:
    address: ":443"
    http3: {}

certificatesResolvers:
  letsencrypt:
    acme:
      caServer: https://acme%{if letsencrypt_staging}-staging%{endif}-v02.api.letsencrypt.org/directory
      email: ${letsencrypt_email}
      storage: /etc/traefik/acme.json
      dnsChallenge:
        provider: cloudflare
        delayBeforeCheck: 15
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"

api:
  dashboard: false

accesslog:
  format: json
  filePath: /var/log/traefik/access.log
  fields:
    defaultMode: keep
    headers:
      defaultMode: drop
      names:
        User-Agent: redact
        Content-Type: keep
        Referer: keep

log:
  level: INFO
  filePath: /var/log/traefik/traefik.log

providers:
  file:
    filename: /etc/traefik/static.yaml

  consulCatalog:
    endpoint:
      scheme: http
      address: "127.0.0.1:8500"
    connectAware: true
    constraints: "Tag(\`http\`)"
    exposedByDefault: false
EOF
cat <<EOF > /etc/traefik/static.yaml
http:
  routers:
    consul:
      tls:
        certResolver: letsencrypt
      rule: "Host(\`${consul_fqdn}\`)"
      service: consul
    
    nomad:
      tls:
        certResolver: letsencrypt
      rule: "Host(\`${nomad_fqdn}\`)"
      service: nomad
  
  services:
    consul:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8500"
    
    nomad:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:4646"
EOF
cat <<EOF > /etc/traefik/traefik.env
CF_DNS_API_TOKEN=${cloudflare_api_token}
CF_ZONE_API_TOKEN=${cloudflare_api_token}
EOF

# Setup Traefik systemd service
cat <<EOF > /etc/systemd/system/traefik.service
[Unit]
Description=Traefik
Documentation=https://docs.traefik.io/traefik/
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/traefik
AssertPathExists=/etc/traefik/traefik.yaml

[Service]
User=traefik
Group=traefik
AmbientCapabilities=CAP_NET_BIND_SERVICE
EnvironmentFile=-/etc/traefik/traefik.env
Type=notify
ExecStart=/usr/local/bin/traefik --configfile=/etc/traefik/traefik.yaml
Restart=always
WatchdogSec=1s
ProtectSystem=strict
PrivateTmp=true
ProtectHome=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true
ReadWritePaths=/etc/traefik/acme.json
ReadOnlyPaths=/etc/traefik/traefik.yaml
ReadOnlyPaths=/etc/traefik/static.yaml
ReadWritePaths=/var/log/traefik

[Install]
WantedBy=multi-user.target
EOF

useradd -r -s /bin/false -U -M traefik

echo "{}" > /etc/traefik/acme.json
mkdir -p /var/log/traefik

chown -R traefik:traefik /etc/traefik /var/log/traefik
chmod 600 /etc/traefik/acme.json

echo "net.core.rmem_max=2500000" >> /etc/sysctl.d/11-traefik.conf
sysctl -p /etc/sysctl.d/11-traefik.conf

systemctl daemon-reload
systemctl enable traefik.service
systemctl start traefik.service

# Configure Traefik log rotation
cat <<EOF > /etc/logrotate.d/traefik
/var/log/traefik/*.log {
  size 10M
  rotate 5
  missingok
  notifempty
  postrotate
    systemctl kill --signal=USR1 traefik
  endscript
}
EOF
