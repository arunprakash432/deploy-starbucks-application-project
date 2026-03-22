#!/bin/bash

set -e

echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

echo "Creating Prometheus user..."
sudo useradd --no-create-home --shell /bin/false prometheus || true

echo "Creating directories..."
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

cd /tmp

PROM_VERSION="2.52.0"

echo "Downloading Prometheus v$PROM_VERSION..."
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

echo "Extracting Prometheus..."
tar -xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

cd prometheus-${PROM_VERSION}.linux-amd64

echo "Copying binaries..."
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

echo "Copying configuration files..."
sudo cp prometheus.yml /etc/prometheus/
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus

echo "Creating systemd service..."

sudo bash -c 'cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF'

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Starting Prometheus..."
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "Prometheus installation completed!"
echo "Access Prometheus at: http://localhost:9090"