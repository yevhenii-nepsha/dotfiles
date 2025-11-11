#!/bin/bash
# Pi-hole setup script for Multipass VM

set -e

echo "=== Installing Docker ==="

# Update package list
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

echo "=== Docker installed successfully ==="
echo "Note: You may need to log out and back in for docker group to take effect"
echo ""
echo "=== Creating Pi-hole directories ==="

# Create directories for Pi-hole data
mkdir -p ~/pihole/etc-pihole
mkdir -p ~/pihole/etc-dnsmasq.d

echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "1. Log out and back in (or run: newgrp docker)"
echo "2. Copy docker-compose files to VM"
echo "3. Create .env file with your settings"
echo "4. Run: docker compose up -d"
