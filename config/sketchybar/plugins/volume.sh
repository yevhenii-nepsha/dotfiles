#!/bin/bash

# Volume plugin with popup for audio output device selection.
# - volume_change: updates icon/label based on current volume
# - mouse.clicked: toggles popup with output device list
# - Popup item click: switches output device via SwitchAudioSource
#
# Requires: switchaudio-osx (brew install switchaudio-osx)

POPUP_PARENT="volume"
ACTIVE_COLOR=0xff80a0ff    # moonfly blue — active device
INACTIVE_COLOR=0xffc6c6c6  # moonfly white — inactive device

update_icon() {
  VOLUME="$1"
  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾" ;;
    [3-5][0-9])     ICON="󰖀" ;;
    [1-9]|[1-2][0-9]) ICON="󰕿" ;;
    *)              ICON="󰖁" ;;
  esac
  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%"
}

update_popup() {
  # Requires SwitchAudioSource
  if ! command -v SwitchAudioSource &>/dev/null; then
    sketchybar --add item volume.no_sas popup."$POPUP_PARENT" \
               --set volume.no_sas label="SwitchAudioSource not found" \
                     icon.drawing=off \
                     label.padding_left=10 \
                     label.padding_right=10 \
                     click_script="sketchybar --set $POPUP_PARENT popup.drawing=off"
    return
  fi

  # Remove old popup items
  EXISTING=$(sketchybar --query "$POPUP_PARENT" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    items = d.get('popup', {}).get('items', [])
    print(' '.join(items))
except:
    pass
" 2>/dev/null)

  for item in $EXISTING; do
    sketchybar --remove "$item" 2>/dev/null
  done

  # Get current output device
  CURRENT=$(SwitchAudioSource -c -t output 2>/dev/null)

  # Get all output devices and build popup items
  local i=0
  while IFS= read -r device; do
    [ -z "$device" ] && continue
    ITEM_NAME="volume.device.$i"

    if [ "$device" = "$CURRENT" ]; then
      ICON="󰓃"
      ICON_CLR="$ACTIVE_COLOR"
      LABEL_CLR="$ACTIVE_COLOR"
    else
      ICON="󰓃"
      ICON_CLR="$INACTIVE_COLOR"
      LABEL_CLR="$INACTIVE_COLOR"
    fi

    # Escape single quotes in device name for click_script
    DEVICE_ESCAPED="${device//\'/\'\\\'\'}"

    sketchybar --add item "$ITEM_NAME" popup."$POPUP_PARENT"       \
               --set "$ITEM_NAME"                                   \
                     label="$device"                                \
                     label.font="JetBrainsMono Nerd Font:Medium:13.0" \
                     label.color="$LABEL_CLR"                       \
                     icon="$ICON"                                   \
                     icon.color="$ICON_CLR"                         \
                     icon.padding_left=8                            \
                     label.padding_right=10                         \
                     click_script="SwitchAudioSource -s '$DEVICE_ESCAPED' -t output && sketchybar --set $POPUP_PARENT popup.drawing=off && sketchybar --trigger volume_devices_refresh"

    i=$((i + 1))
  done < <(SwitchAudioSource -a -t output 2>/dev/null)

  # Empty state
  if [ "$i" -eq 0 ]; then
    sketchybar --add item volume.no_devices popup."$POPUP_PARENT" \
               --set volume.no_devices label="No output devices" \
                     icon.drawing=off \
                     label.padding_left=10 \
                     label.padding_right=10 \
                     click_script="sketchybar --set $POPUP_PARENT popup.drawing=off"
  fi
}

case "$SENDER" in
  volume_change)
    update_icon "$INFO"
    ;;
  mouse.clicked)
    update_popup
    sketchybar --set "$NAME" popup.drawing=toggle
    ;;
  mouse.exited|mouse.exited.global|front_app_switched)
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  volume_devices_refresh)
    # Refresh popup content after device switch (popup is already closed)
    ;;
  *)
    # On initial load, get volume from osascript if $INFO is empty
    if [ -n "$INFO" ]; then
      update_icon "$INFO"
    else
      VOL=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
      update_icon "${VOL:-0}"
    fi
    ;;
esac
