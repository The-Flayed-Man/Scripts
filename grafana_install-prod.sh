#!/bin/bash

# Check and add Grafana repository
repo_file="/etc/yum.repos.d/grafana.repo"
if [ ! -f "$repo_file" ]; then
    sudo tee "$repo_file" << EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
else
    echo "Grafana repository already added."
fi

# Check and install Grafana
if ! rpm -q grafana >/dev/null; then
    dnf install -y grafana
else
    echo "Grafana is already installed."
fi

# Start and enable Grafana service
if ! systemctl is-active --quiet grafana-server; then
    systemctl start grafana-server
fi
if ! systemctl is-enabled --quiet grafana-server; then
    systemctl enable grafana-server
fi
systemctl status grafana-server

# Configure the firewall
if ! sudo firewall-cmd --list-ports | grep -q "3000/tcp"; then
    sudo firewall-cmd --add-port=3000/tcp --permanent
    sudo firewall-cmd --reload
else
    echo "Port 3000 is already open."
fi

# Echo default login credentials
echo "Default login credentials are:"
echo "Username: admin"
echo "Password: admin"

# Echo Grafana config file location
echo "Grafana config file /etc/grafana/grafana.ini"

# Fetch and echo the server's IP address
ipaddress=$(hostname -I | cut -d' ' -f1)
echo "Grafana dashboard URL: http://$ipaddress:3000/"
