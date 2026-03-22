#!/bin/bash

# Exit if any command fails
set -e

echo "Updating system packages..."
sudo apt update -y

echo "Installing required dependencies..."
sudo apt install -y apt-transport-https software-properties-common wget

echo "Adding Grafana GPG key..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "Adding Grafana repository..."
echo "deb https://packages.grafana.com/oss/deb stable main" | \
sudo tee /etc/apt/sources.list.d/grafana.list

echo "Updating package list..."
sudo apt update -y

echo "Installing Grafana..."
sudo apt install -y grafana

echo "Starting Grafana service..."
sudo systemctl start grafana-server

echo "Enabling Grafana to start on boot..."
sudo systemctl enable grafana-server

echo "Checking Grafana service status..."
sudo systemctl status grafana-server --no-pager

echo "Grafana installation completed!"
echo "Access Grafana at: http://localhost:3000"
echo "Default login -> username: admin | password: admin"