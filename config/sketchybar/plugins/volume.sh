#!/bin/bash
# Volume slider: scroll to change, hover to expand, click on the slider to set.

source "$CONFIG_DIR/colors.sh"

STEP=3

TARGET_FILE="${TMPDIR:-/tmp}/sketchybar_volume_target"
LOCK_DIR="${TMPDIR:-/tmp}/sketchybar_volume_lock"

# osascript takes ~150ms, so fast scrolling would queue up calls. Store the
# latest target and let a single background worker apply it until it settles.
set_volume() {
  echo "$1" > "$TARGET_FILE"
  mkdir "$LOCK_DIR" 2>/dev/null || return 0
  (
    APPLIED=""
    while TARGET=$(cat "$TARGET_FILE") && [ "$TARGET" != "$APPLIED" ]; do
      osascript -e "set volume output volume $TARGET"
      APPLIED=$TARGET
    done
    rmdir "$LOCK_DIR"
  ) &
}

render() {
  local VOLUME=$1
  case "$VOLUME" in
    0) ICON="󰖁" ;;
    [0-9]) ICON="󰕿" ;;
    [0-5][0-9]) ICON="󰖀" ;;
    *) ICON="󰕾" ;;
  esac
  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" slider.percentage="$VOLUME"
}

case "$SENDER" in
  volume_change)
    render "$INFO"
    ;;
  mouse.scrolled)
    CURRENT=$(sketchybar --query "$NAME" | jq -r '.slider.percentage')
    if [ "$SCROLL_DELTA" -gt 0 ]; then
      NEW=$((CURRENT + STEP))
    else
      NEW=$((CURRENT - STEP))
    fi
    [ "$NEW" -gt 100 ] && NEW=100
    [ "$NEW" -lt 0 ] && NEW=0
    render "$NEW"
    set_volume "$NEW"
    ;;
  mouse.clicked)
    set_volume "$PERCENTAGE"
    ;;
  mouse.entered)
    sketchybar --animate tanh 15 --set "$NAME" slider.width=100 label.drawing=on
    ;;
  mouse.exited)
    sketchybar --animate tanh 15 --set "$NAME" slider.width=0 label.drawing=off
    ;;
  *)
    render "$(osascript -e 'output volume of (get volume settings)')"
    ;;
esac
