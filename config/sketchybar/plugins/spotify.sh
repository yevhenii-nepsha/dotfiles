#!/bin/bash
# Show the current Spotify track. Click toggles play/pause.

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  osascript -e 'tell application "Spotify" to playpause'
  exit 0
fi

if [ "$SENDER" = "spotify_change" ]; then
  STATE=$(echo "$INFO" | jq -r '."Player State" // empty')
  TRACK=$(echo "$INFO" | jq -r '.Name // empty')
  ARTIST=$(echo "$INFO" | jq -r '.Artist // empty')
elif pgrep -xq Spotify; then
  # Startup or forced update: ask Spotify directly.
  IFS=$'\t' read -r STATE TRACK ARTIST < <(osascript -e '
    tell application "Spotify"
      set s to player state as string
      if s is "stopped" then return "Stopped"
      return s & tab & (name of current track) & tab & (artist of current track)
    end tell')
fi

case "$STATE" in
  Playing | playing) ICON="󰐊"; COLOR="$GREEN" ;;
  Paused | paused) ICON="󰏤"; COLOR="$GREY" ;;
  *)
    sketchybar --set "$NAME" drawing=off
    exit 0
    ;;
esac

export LC_ALL=en_US.UTF-8 # count characters, not bytes (Cyrillic titles)
MAX_CHARS=80
LABEL="$ARTIST — $TRACK"
if [ "${#LABEL}" -gt "$MAX_CHARS" ]; then
  LABEL="${LABEL:0:$((MAX_CHARS - 1))}…"
fi

sketchybar --set "$NAME" drawing=on \
                         icon="$ICON" icon.color="$COLOR" \
                         label="$LABEL"
