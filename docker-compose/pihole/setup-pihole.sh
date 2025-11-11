#!/bin/bash
# Automated Pi-hole setup script for macOS with Multipass VM
# This script will install Multipass, create VM, install Docker, and setup Pi-hole

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VM_NAME="mother"
VM_CPUS="2"
VM_MEMORY="2G"
VM_DISK="20G"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check and install Multipass
install_multipass() {
    print_info "Checking for Multipass installation..."

    if command_exists multipass; then
        print_success "Multipass is already installed"
        multipass version
    else
        print_info "Multipass not found. Installing via Homebrew..."

        if ! command_exists brew; then
            print_error "Homebrew is not installed. Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi

        brew install --cask multipass
        print_success "Multipass installed successfully"
    fi
}

# Step 2: Get network interface for bridged network
get_network_interface() {
    print_info "Detecting network interface..."

    # Find active network interface (usually en0 for WiFi, en1 for Ethernet)
    local interface=$(route get default | grep interface | awk '{print $2}')

    if [ -z "$interface" ]; then
        print_warning "Could not auto-detect network interface"
        echo -n "Enter network interface name (usually en0 or en1): "
        read interface
    fi

    echo "$interface"
}

# Step 3: Configure Pi-hole settings
configure_pihole() {
    print_info "Configuring Pi-hole settings..."

    # Check if .env exists
    if [ -f "$SCRIPT_DIR/.env" ]; then
        print_info "Found existing .env file"
        echo -n "Do you want to use existing .env? (y/n): "
        read use_existing

        if [ "$use_existing" != "y" ]; then
            create_env_file
        fi
    else
        create_env_file
    fi
}

create_env_file() {
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"

    # Ask for password
    echo -n "Enter Pi-hole admin password: "
    read -s pihole_password
    echo

    # Update .env file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/PIHOLE_PASSWORD=.*/PIHOLE_PASSWORD=$pihole_password/" "$SCRIPT_DIR/.env"
    else
        sed -i "s/PIHOLE_PASSWORD=.*/PIHOLE_PASSWORD=$pihole_password/" "$SCRIPT_DIR/.env"
    fi

    print_success ".env file configured"
}

# Step 4: Create and provision VM
create_vm() {
    print_info "Checking if VM '$VM_NAME' exists..."

    if multipass list | grep -q "$VM_NAME"; then
        print_warning "VM '$VM_NAME' already exists"
        echo -n "Do you want to delete and recreate it? (y/n): "
        read recreate

        if [ "$recreate" = "y" ]; then
            print_info "Deleting existing VM..."
            multipass delete "$VM_NAME"
            multipass purge
            print_success "VM deleted"
        else
            print_info "Using existing VM"
            return 0
        fi
    fi

    local network_interface=$(get_network_interface)

    print_info "Creating VM '$VM_NAME' with bridged network on $network_interface..."
    multipass launch --name "$VM_NAME" \
        --cpus "$VM_CPUS" \
        --memory "$VM_MEMORY" \
        --disk "$VM_DISK" \
        --network "name=$network_interface,mode=auto"

    # Wait for VM to be ready
    print_info "Waiting for VM to be ready..."
    sleep 10

    print_success "VM created successfully"
    multipass info "$VM_NAME"
}

# Step 5: Provision VM with Docker and Pi-hole
provision_vm() {
    print_info "Provisioning VM with Docker and Pi-hole..."

    # Transfer provision script
    print_info "Transferring provision script to VM..."
    multipass transfer "$SCRIPT_DIR/vm-provision.sh" "$VM_NAME:/home/ubuntu/"

    # Transfer Pi-hole configuration files
    print_info "Transferring Pi-hole configuration..."
    multipass transfer "$SCRIPT_DIR/compose.yml" "$VM_NAME:/home/ubuntu/"
    multipass transfer "$SCRIPT_DIR/.env" "$VM_NAME:/home/ubuntu/"

    # Execute provision script in VM
    print_info "Installing Docker in VM..."
    multipass exec "$VM_NAME" -- bash -c "chmod +x /home/ubuntu/vm-provision.sh && /home/ubuntu/vm-provision.sh"

    print_success "VM provisioned successfully"
}

# Step 6: Start Pi-hole
start_pihole() {
    print_info "Starting Pi-hole in VM..."

    multipass exec "$VM_NAME" -- bash -c "cd /home/ubuntu/pihole && docker compose up -d"

    sleep 5

    # Check if Pi-hole is running
    if multipass exec "$VM_NAME" -- docker ps | grep -q pihole; then
        print_success "Pi-hole is running!"
    else
        print_error "Pi-hole failed to start. Check logs with:"
        echo "  multipass exec $VM_NAME -- docker compose -f /home/ubuntu/pihole/compose.yml logs"
        exit 1
    fi
}

# Step 7: Display final instructions
show_instructions() {
    local vm_ip=$(multipass info "$VM_NAME" | grep IPv4 | grep "192.168.1" | awk '{print $2}')

    if [ -z "$vm_ip" ]; then
        print_warning "Could not detect VM IP address with 192.168.1.x"
        vm_ip=$(multipass info "$VM_NAME" | grep IPv4 | head -1 | awk '{print $2}')
    fi

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Pi-hole setup completed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    print_info "Pi-hole Admin Panel:"
    echo "  URL: http://$vm_ip:8053/admin"
    echo "  Password: (check your .env file)"
    echo
    print_info "Next steps to enable network-wide ad blocking:"
    echo
    echo "  1. Open AirPort Utility on your Mac"
    echo "  2. Select your Airport Extreme router"
    echo "  3. Click 'Edit'"
    echo "  4. Go to 'Internet' tab → 'Internet Options'"
    echo "  5. In DHCP section, set DNS Servers:"
    echo "     - Primary DNS: $vm_ip"
    echo "     - Secondary DNS: 8.8.8.8 (fallback)"
    echo "  6. Click 'Save' and wait for router to restart"
    echo "  7. Reconnect your devices to WiFi"
    echo
    print_info "Useful commands:"
    echo "  - Access VM: multipass shell $VM_NAME"
    echo "  - View Pi-hole logs: multipass exec $VM_NAME -- docker compose -f /home/ubuntu/pihole/compose.yml logs -f"
    echo "  - Restart Pi-hole: multipass exec $VM_NAME -- docker compose -f /home/ubuntu/pihole/compose.yml restart"
    echo "  - Stop Pi-hole: multipass exec $VM_NAME -- docker compose -f /home/ubuntu/pihole/compose.yml down"
    echo
}

# Main execution
main() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Pi-hole Automated Setup for macOS with Multipass"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    install_multipass
    configure_pihole
    create_vm
    provision_vm
    start_pihole
    show_instructions
}

# Run main function
main
