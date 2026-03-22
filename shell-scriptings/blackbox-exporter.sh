#!/bin/bash

# Variables
VERSION="0.25.0"
USER="blackbox"
INSTALL_DIR="/opt/blackbox_exporter"

echo "Updating system..."
sudo apt update -y

echo "Creating blackbox user..."
sudo useradd --no-create-home --shell /bin/false $USER

echo "Downloading Blackbox Exporter..."
wget https://github.com/prometheus/blackbox_exporter/releases/download/v${VERSION}/blackbox_exporter-${VERSION}.linux-amd64.tar.gz

echo "Extracting package..."
tar -xvf blackbox_exporter-${VERSION}.linux-amd64.tar.gz

echo "Installing..."
sudo mkdir -p $INSTALL_DIR
sudo cp blackbox_exporter-${VERSION}.linux-amd64/blackbox_exporter $INSTALL_DIR
sudo cp blackbox_exporter-${VERSION}.linux-amd64/blackbox.yml $INSTALL_DIR

echo "Setting permissions..."
sudo chown -R $USER:$USER $INSTALL_DIR

echo "Creating systemd service..."

sudo bash -c 'cat <<EOF > /etc/systemd/system/blackbox_exporter.service
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=blackbox
Group=blackbox
Type=simple
ExecStart=/opt/blackbox_exporter/blackbox_exporter --config.file=/opt/blackbox_exporter/blackbox.yml

[Install]
WantedBy=multi-user.target
EOF'

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Starting Blackbox Exporter..."
sudo systemctl enable blackbox_exporter
sudo systemctl start blackbox_exporter

echo "Checking service status..."
sudo systemctl status blackbox_exporter --no-pager

echo "Blackbox Exporter installation completed!"
echo "Access metrics at: http://localhost:9115/metrics"