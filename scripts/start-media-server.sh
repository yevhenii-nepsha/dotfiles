#!/bin/bash
# Wait for volume to be mounted, then start media server containers

VOLUME_PATH="/Volumes/archive/music"
COMPOSE_FILE="$HOME/.dotfiles/docker-compose/media/compose.yml"
LOG_FILE="$HOME/Library/Logs/media-server-start.log"
MAX_WAIT=300  # 5 minutes max wait

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "=== Script started ==="

# Wait for volume
waited=0
while [ ! -d "$VOLUME_PATH" ]; do
    if [ $waited -ge $MAX_WAIT ]; then
        log "ERROR: Volume not mounted after ${MAX_WAIT}s, giving up"
        exit 1
    fi
    sleep 5
    waited=$((waited + 5))
done

log "Volume mounted after ${waited}s"

# Wait a bit more for filesystem to be ready
sleep 5

# Start containers
log "Starting docker compose..."
/Applications/Docker.app/Contents/Resources/bin/docker compose -f "$COMPOSE_FILE" up -d >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    log "=== Containers started successfully ==="
else
    log "ERROR: Failed to start containers"
    exit 1
fi
