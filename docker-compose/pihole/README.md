# Pi-hole Docker Setup

Network-wide ad blocking and DNS server for your home network.

## What is Pi-hole?

Pi-hole is a DNS-based ad blocker that:
- Blocks ads and trackers at the network level (works on all devices)
- Speeds up web browsing by blocking unwanted content
- Provides detailed statistics about DNS queries
- Works for phones, tablets, Smart TVs, IoT devices

## Prerequisites

- Multipass VM with bridged network (or Linux server)
- Access to your router settings (Apple Airport Extreme)
- VM must be always running for network DNS to work

## Quick Start (Automated Setup)

**Recommended:** Use the automated setup script for one-command installation.

```bash
cd ~/.dotfiles/docker-compose/pihole
./setup-pihole.sh
```

This script will:
- ✅ Install Multipass (if not installed)
- ✅ Create Ubuntu VM with bridged network
- ✅ Install Docker in VM
- ✅ Disable systemd-resolved (frees port 53)
- ✅ Deploy Pi-hole with your configuration
- ✅ Display router configuration instructions

**Requirements:**
- macOS with Homebrew installed
- Admin access to Apple Airport Extreme router

After running the script, follow the displayed instructions to configure your router DNS settings.

---

## Manual Setup Instructions

If you prefer manual setup or need to troubleshoot, follow these detailed instructions:

### Option A: Multipass VM Setup (Recommended for macOS)

This is the recommended approach for macOS hosts, as Docker on macOS cannot bind to port 53 due to system DNS conflicts.

#### 1. Install Docker in VM

Copy and run the setup script in your Multipass VM:

```bash
# Copy setup script to VM
multipass transfer setup-vm.sh mother:/home/ubuntu/

# Enter VM
multipass shell mother

# Run setup script
chmod +x setup-vm.sh
./setup-vm.sh

# Reload docker group (or logout/login)
newgrp docker
```

#### 2. Copy Pi-hole Configuration

From your Mac host:

```bash
# Transfer files to VM
multipass transfer compose.yml mother:/home/ubuntu/pihole/
multipass transfer .env.example mother:/home/ubuntu/pihole/
```

#### 3. Configure Environment

Inside the VM:

```bash
cd ~/pihole
cp .env.example .env
nano .env
```

**Required changes in `.env`:**
- `PIHOLE_PASSWORD` - Set a strong password for web admin
- `PIHOLE_DATA_PATH=/home/ubuntu/pihole` - Already set correctly
- `TIMEZONE` - Your timezone (default: `Europe/Kyiv`)

**Optional changes:**
- `UPSTREAM_DNS_1` and `UPSTREAM_DNS_2` - Upstream DNS servers (default: Cloudflare)

Note: Setup script already created data directories (`~/pihole/etc-pihole` and `~/pihole/etc-dnsmasq.d`)

#### 4. Start Pi-hole

```bash
cd ~/pihole
docker compose up -d
```

Check if running:

```bash
docker compose ps
docker compose logs
```

#### 5. Access Web Interface

Get your VM's IP address:

```bash
multipass info mother | grep IPv4
```

Use the bridged network IP (e.g., `192.168.1.23`), then open in browser:
- `http://192.168.1.23:8053/admin`

Login with the password you set in `.env` file.

#### 6. Configure Apple Airport Extreme Router

To make all devices in your network use Pi-hole:

1. Open **AirPort Utility** (macOS) or access web interface
2. Select your Airport Extreme router
3. Click **Edit**
4. Go to **Internet** tab
5. Click **Internet Options** button
6. In **DHCP** section, find **DNS Servers**
7. Set Primary DNS to your VM's IP: `192.168.1.23` (from multipass info)
8. Set Secondary DNS to `8.8.8.8` (fallback if Pi-hole is down)
9. Click **Save** and wait for router to restart

#### 7. Test Pi-hole

After router restarts:

1. Reconnect your devices to WiFi
2. Visit a website with ads
3. Check Pi-hole admin panel to see blocked queries
4. Test DNS resolution: `nslookup pi.hole`

---

### Option B: Linux Server Setup

If running on a native Linux server instead of Multipass VM:

#### 1. Configuration

Copy the example environment file and customize it:

```bash
cd ~/.dotfiles/docker-compose/pihole
cp .env.example .env
nano .env
```

**Required changes in `.env`:**
- `PIHOLE_PASSWORD` - Set a strong password for web admin
- `PIHOLE_DATA_PATH` - Set path for Pi-hole data (e.g., `/Users/username/.config/pihole`)
- `TIMEZONE` - Your timezone (default: `Europe/Kyiv`)

**Optional changes:**
- `UPSTREAM_DNS_1` and `UPSTREAM_DNS_2` - Upstream DNS servers (default: Cloudflare)

### 2. Create Data Directory

Create the directory for Pi-hole data:

```bash
mkdir -p /path/to/.config/pihole
```

Replace `/path/to/.config/pihole` with your actual path from `.env` file.

### 3. Start Pi-hole

Start the Pi-hole container:

```bash
docker compose up -d
```

Check if it's running:

```bash
docker compose ps
docker compose logs
```

### 4. Access Web Interface

Open your browser and navigate to:
- `http://[SERVER_IP]:8053/admin`
- Example: `http://192.168.1.100:8053/admin`

Login with the password you set in `.env` file.

### 5. Configure Apple Airport Extreme Router

To make all devices in your network use Pi-hole:

1. Open **AirPort Utility** (macOS) or access web interface
2. Select your Airport Extreme router
3. Click **Edit**
4. Go to **Internet** tab
5. Click **Internet Options** button
6. In **DHCP** section, find **DNS Servers**
7. Set Primary DNS to your server's local IP (e.g., `192.168.1.100`)
8. Set Secondary DNS to `8.8.8.8` (fallback if Pi-hole is down)
9. Click **Save** and wait for router to restart

**Important:** Write down your server's local IP address. You can find it with:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### 6. Test Pi-hole

After router restarts:

1. Reconnect your devices to WiFi
2. Visit a website with ads
3. Check Pi-hole admin panel to see blocked queries
4. Test DNS resolution: `nslookup pi.hole`

## Managing Pi-hole

### View Logs
```bash
docker compose logs -f
```

### Restart Pi-hole
```bash
docker compose restart
```

### Stop Pi-hole
```bash
docker compose down
```

### Update Pi-hole
```bash
docker compose pull
docker compose up -d
```

## Pi-hole Admin Features

Access at `http://[SERVER_IP]:8053/admin`:

- **Dashboard** - Real-time statistics and graphs
- **Query Log** - See all DNS queries and what was blocked
- **Whitelist** - Unblock specific domains if needed
- **Blacklist** - Add custom domains to block
- **Adlists** - Manage blocklist sources
- **Settings** - Configure Pi-hole behavior

## Troubleshooting

### Pi-hole not blocking ads

- Check if router DNS is set correctly
- Reconnect devices to WiFi to get new DNS settings
- Verify Pi-hole is running: `docker compose ps`
- Check if queries appear in Pi-hole dashboard

### Internet stops working

- Pi-hole might be down - check with `docker compose ps`
- Router should use secondary DNS (8.8.8.8) as fallback
- Temporarily change router DNS back to `8.8.8.8` if needed

### Website not loading (false positive)

- Check Pi-hole Query Log to see if domain is blocked
- Whitelist the domain in Pi-hole admin panel
- Or temporarily disable Pi-hole: `docker compose stop`

### Cannot access Pi-hole admin panel

- Verify Pi-hole is running: `docker compose ps`
- Check server IP address is correct
- Try: `http://[SERVER_IP]:8053/admin` (note the `/admin`)

## Port Information

- **53/tcp & 53/udp** - DNS service (used by your devices)
- **8053/tcp** - Web admin interface (custom port to avoid conflicts)

## Recommended Blocklists

Pi-hole comes with default blocklists, but you can add more:

1. Go to Pi-hole admin → **Adlists**
2. Add popular lists:
   - https://dbl.oisd.nl/ (comprehensive)
   - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

3. Update Gravity: **Tools** → **Update Gravity**

## Security Notes

- Web interface is on local network only (not exposed to internet)
- Change default password immediately
- Keep Pi-hole updated regularly
- Monitor Query Log for suspicious DNS queries

## Backup and Restore

### Backup Settings
```bash
# From Pi-hole admin panel: Settings → Teleporter → Backup
```

### Manual Backup
```bash
cp -r /path/to/.config/pihole /path/to/backup/location
```

## Links

- [Pi-hole Official Documentation](https://docs.pi-hole.net/)
- [Pi-hole Docker Hub](https://hub.docker.com/r/pihole/pihole)
- [Pi-hole Discourse Community](https://discourse.pi-hole.net/)
