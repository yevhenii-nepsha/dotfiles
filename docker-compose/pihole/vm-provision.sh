#!/bin/bash
# VM provisioning script for Pi-hole setup
# This script runs inside the Ubuntu VM to install Docker and configure Pi-hole

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo_info "Starting VM provisioning..."

# Update system
echo_info "Updating package lists..."
sudo apt-get update -qq

# Install prerequisites
echo_info "Installing prerequisites..."
sudo apt-get install -y -qq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo_info "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo_info "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo_info "Installing Docker..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

# Add user to docker group
echo_info "Adding user to docker group..."
sudo usermod -aG docker $USER

echo_success "Docker installed successfully"

# Disable systemd-resolved to free port 53
echo_info "Disabling systemd-resolved to free port 53..."
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Remove resolv.conf symlink
sudo rm -f /etc/resolv.conf

# Create new resolv.conf with Cloudflare DNS
echo_info "Configuring DNS..."
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf > /dev/null

# Make resolv.conf immutable to prevent overwriting
sudo chattr +i /etc/resolv.conf

echo_success "systemd-resolved disabled, port 53 is now available"

# Create Pi-hole directory structure
echo_info "Creating Pi-hole directories..."
mkdir -p /home/ubuntu/pihole/etc-pihole
mkdir -p /home/ubuntu/pihole/etc-dnsmasq.d

# Move configuration files to pihole directory
if [ -f /home/ubuntu/compose.yml ]; then
    mv /home/ubuntu/compose.yml /home/ubuntu/pihole/
fi

if [ -f /home/ubuntu/.env ]; then
    mv /home/ubuntu/.env /home/ubuntu/pihole/
fi

echo_success "Pi-hole directories created"

# Test Docker installation
echo_info "Testing Docker installation..."
docker --version

echo_success "VM provisioning completed successfully"
echo
echo "Pi-hole is ready to be started with:"
echo "  cd /home/ubuntu/pihole && docker compose up -d"
