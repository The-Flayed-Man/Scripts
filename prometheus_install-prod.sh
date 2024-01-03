#!/bin/bash

# Script log file
LOG_FILE="/var/log/prometheus_installation.log"

# Function to log messages
log_message() {
    echo "$(date): $1" | tee -a $LOG_FILE
}

log_message "Starting Prometheus and Node Exporter installation script."


# Version Parameterization
# Function to fetch latest version from GitHub
fetch_latest_release_version() {
    curl -s "https://api.github.com/repos/prometheus/$1/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"([^"]+)".*/\1/' | \
    sed -E 's/^v//'
}

# Fetching latest versions
log_message "Fetching latest versions..."
PROMETHEUS_VERSION=$(fetch_latest_release_version prometheus)
NODE_EXPORTER_VERSION=$(fetch_latest_release_version node_exporter)

if [ -z "$PROMETHEUS_VERSION" ] || [ -z "$NODE_EXPORTER_VERSION" ]; then
    log_message "Error fetching versions. Exiting."
    exit 1
fi

log_message "Latest Prometheus version: $PROMETHEUS_VERSION"
log_message "Latest Node Exporter version: $NODE_EXPORTER_VERSION"
#PROMETHEUS_VERSION="2.33.5"
#NODE_EXPORTER_VERSION="1.7.0"

# Updating the system
log_message "Updating the system..."
dnf update -y >>$LOG_FILE 2>&1 || { log_message "Failed to update the system. Exiting."; exit 1; }

# Checking if the Prometheus user exists
log_message "Checking for Prometheus user..."
if id "prometheus" &>/dev/null; then
    log_message "Prometheus user already exists."
else
    # Creating a user for Prometheus
    log_message "Creating Prometheus user..."
    useradd --no-create-home --shell /bin/false prometheus || { log_message "Failed to create Prometheus user. Exiting."; exit 1; }
fi

# Checking and creating necessary directories for Prometheus
log_message "Checking and creating necessary directories..."
for dir in /etc/prometheus /var/lib/prometheus; do
    if [ -d "$dir" ]; then
        log_message "$dir already exists."
    else
        mkdir "$dir" && chown prometheus:prometheus "$dir" || { log_message "Failed to create $dir. Exiting."; exit 1; }
    fi
done

# Check if Prometheus binaries are already present
log_message "Checking for Prometheus binaries..."
if [ -f "/usr/local/bin/prometheus" ] && [ -f "/usr/local/bin/promtool" ]; then
    log_message "Prometheus binaries already exist."
else
    # Downloading and installing Prometheus
    log_message "Downloading and installing Prometheus..."
    cd /tmp && \
    curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
    tar xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/ && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/ && \
    chown prometheus:prometheus /usr/local/bin/prometheus && \
    chown prometheus:prometheus /usr/local/bin/promtool || { log_message "Failed to install Prometheus. Exiting."; exit 1; }
fi

# Check if Prometheus configuration files are present
log_message "Checking for Prometheus configuration files..."
if [ -d "/etc/prometheus/consoles" ] && [ -d "/etc/prometheus/console_libraries" ]; then
    log_message "Prometheus configuration files already exist."
else
    # Moving configuration files and setting permissions
    log_message "Moving configuration files and setting permissions..."
    cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus && \
    cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml /etc/prometheus && \
    chown -R prometheus:prometheus /etc/prometheus/consoles && \
    chown -R prometheus:prometheus /etc/prometheus/console_libraries || { log_message "Failed to set up Prometheus configuration files. Exiting."; exit 1; }
fi

# Creating a systemd service file for Prometheus
log_message "Setting up Prometheus systemd service..."
if [ -f "/etc/systemd/system/prometheus.service" ]; then
    log_message "Prometheus systemd service file already exists."
else
    # Creating and enabling the Prometheus service
    echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/prometheus.service || { log_message "Failed to create Prometheus systemd service file. Exiting."; exit 1; }
fi

# Reloading systemd and starting/enabling Prometheus service
log_message "Reloading systemd and managing Prometheus service..."
systemctl daemon-reload && \
systemctl start prometheus && \
systemctl enable prometheus && \
systemctl status prometheus >>$LOG_FILE 2>&1 || { log_message "Failed to manage Prometheus service. Exiting."; exit 1; }

log_message "Prometheus installation and configuration complete."

# Beginning of Node Exporter installation section
log_message "Starting Node Exporter installation..."

# Check if Node Exporter binary is already present
log_message "Checking for Node Exporter binary..."
if [ -f "/usr/local/bin/node_exporter" ]; then
    log_message "Node Exporter binary already exists."
else
    # Downloading and installing Node Exporter
    log_message "Downloading and installing Node Exporter..."
    cd /tmp && \
    curl -LO https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz && \
    tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz && \
    cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/ && \
    chown prometheus:prometheus /usr/local/bin/node_exporter || { log_message "Failed to install Node Exporter. Exiting."; exit 1; }
fi

# Creating a systemd service file for Node Exporter
log_message "Setting up Node Exporter systemd service..."
if [ -f "/etc/systemd/system/node_exporter.service" ]; then
    log_message "Node Exporter systemd service file already exists."
else
    # Creating and enabling the Node Exporter service
    echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/node_exporter.service || { log_message "Failed to create Node Exporter systemd service file. Exiting."; exit 1; }
fi

# Reloading systemd and starting/enabling Node Exporter service
log_message "Reloading systemd and managing Node Exporter service..."
systemctl daemon-reload && \
systemctl start node_exporter && \
systemctl enable node_exporter && \
systemctl status node_exporter >>$LOG_FILE 2>&1 || { log_message "Failed to manage Node Exporter service. Exiting."; exit 1; }

log_message "Node Exporter installation and configuration complete."

# Fetch and echo the server's IP address
ipaddress=$(hostname -I | cut -d' ' -f1)
echo "Prometheus dashboard URL: http://$ipaddress:9090/"
