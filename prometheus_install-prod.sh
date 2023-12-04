#!/bin/bash

# Check for all updates
updates=$(dnf check-update)

# Check if there are any updates available
if [ -z "$updates" ]; then
    echo "No updates available."
else
    echo "Updates available:"
    echo "$updates"

     read -p "Do you want to install these updates? (y/n): " install_answer
    if [[ "$install_answer" == "y" ]]; then
        # Perform the updates
        dnf update --exclude=kernel*
        echo "Updates have been installed."
    else
        echo "Update installation cancelled."
    fi
fi

    # Check for kernel updates
    kernel_updates=$(echo "$updates" | grep kernel)

    if [ -n "$kernel_updates" ]; then
        echo "Kernel updates available:"
        echo "$kernel_updates"

        # Ask user if they want to update the kernel
        read -p "Do you want to update the kernel? (y/n): " answer
        if [[ "$answer" == "y" ]]; then
            # Update the kernel
            dnf update kernel

            # Ask if the user wants to reboot after kernel update
            read -p "Kernel update complete. Do you want to reboot now? (yes/no): " reboot_answer
            if [[ "$reboot_answer" == "yes" ]]; then
                echo "Rebooting the system!"
                reboot
            else
                echo "Reboot cancelled. Remember to reboot later to apply kernel updates."
            fi
        else
            echo "Kernel update cancelled."
        fi
    else
        echo "No kernel updates available."
    fi
fi
#!/bin/bash

# Updating the system
dnf update -y

# Checking if the Prometheus user exists
if id "prometheus" &>/dev/null; then
    echo "Prometheus user already exists."
else
    # Creating a user for Prometheus
    useradd --no-create-home --shell /bin/false prometheus
fi

# Checking and creating necessary directories for Prometheus
for dir in /etc/prometheus /var/lib/prometheus; do
    if [ -d "$dir" ]; then
        echo "$dir already exists."
    else
        mkdir "$dir"
        chown prometheus:prometheus "$dir"
    fi
done

# Check if Prometheus binaries are already present
if [ -f "/usr/local/bin/prometheus" ] && [ -f "/usr/local/bin/promtool" ]; then
    echo "Prometheus binaries already exist."
else
    # Downloading and installing Prometheus
    cd /tmp
    curl -LO https://github.com/prometheus/prometheus/releases/download/v2.33.5/prometheus-2.33.5.linux-amd64.tar.gz
    tar xvf prometheus-2.33.5.linux-amd64.tar.gz
    cp prometheus-2.33.5.linux-amd64/prometheus /usr/local/bin/
    cp prometheus-2.33.5.linux-amd64/promtool /usr/local/bin/
    chown prometheus:prometheus /usr/local/bin/prometheus
    chown prometheus:prometheus /usr/local/bin/promtool
fi

# Check if Prometheus configuration files are present
if [ -d "/etc/prometheus/consoles" ] && [ -d "/etc/prometheus/console_libraries" ]; then
    echo "Prometheus configuration files already exist."
else
    # Moving configuration files and setting permissions
    cp -r prometheus-2.33.5.linux-amd64/consoles /etc/prometheus
    cp -r prometheus-2.33.5.linux-amd64/console_libraries /etc/prometheus
    cp prometheus-2.33.5.linux-amd64/prometheus.yml /etc/prometheus
    chown -R prometheus:prometheus /etc/prometheus/consoles
    chown -R prometheus:prometheus /etc/prometheus/console_libraries
fi

# Creating a systemd service file for Prometheus
if [ -f "/etc/systemd/system/prometheus.service" ]; then
    echo "Prometheus systemd service file already exists."
else
    # Creating and enabling the Prometheus service
    # (The service content goes here)
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
WantedBy=multi-user.target" | tee /etc/systemd/system/prometheus.service
fi

# Reloading systemd and starting/enabling Prometheus service
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
systemctl status prometheus
echo "Prometheus installation and configuration complete."

# Node Exporter installation checks and processes
# (Similar checks and installation steps for Node Exporter go here)
