# ============================================================================
# Podman Configuration
# ============================================================================
# Docker compatibility layer for Podman
# This file provides aliases and environment variables for seamless
# transition from Docker Desktop to Podman

# ============================================================================
# ALIASES - Docker Compatibility
# ============================================================================
alias docker='podman'
alias docker-compose='podman-compose'

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
# Set DOCKER_HOST for tools that check for Docker socket
# This points to the Podman machine's API socket
export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/podman-api.sock"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Start podman machine if not running
podman-start() {
    if podman machine list --format json 2>/dev/null | grep -q '"Running":true'; then
        echo "✅ Podman machine is already running"
    else
        echo "🔄 Starting podman machine..."
        podman machine start
        echo "✅ Podman machine started"
    fi
}

# Stop podman machine
podman-stop() {
    if podman machine list --format json 2>/dev/null | grep -q '"Running":false'; then
        echo "ℹ️  Podman machine is not running"
    else
        echo "🔄 Stopping podman machine..."
        podman machine stop
        echo "✅ Podman machine stopped"
    fi
}

# Restart podman machine
podman-restart() {
    echo "🔄 Restarting podman machine..."
    podman machine stop 2>/dev/null || true
    podman machine start
    echo "✅ Podman machine restarted"
}

# Show podman machine status
podman-status() {
    echo "Podman Machine Status:"
    echo "━━━━━━━━━━━━━━━━━━━━"
    podman machine list
    echo ""
    echo "Podman Version:"
    echo "━━━━━━━━━━━━━━━"
    podman version | head -n 5
}

# Clean up podman resources
podman-cleanup() {
    echo "🧹 Cleaning up podman resources..."
    echo ""
    echo "Removing stopped containers..."
    podman container prune -f
    echo ""
    echo "Removing unused images..."
    podman image prune -f
    echo ""
    echo "Removing unused volumes..."
    podman volume prune -f
    echo ""
    echo "✅ Cleanup complete"
}
