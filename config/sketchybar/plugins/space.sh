#!/bin/bash
# Highlight the active Space. $SELECTED and $SID are set by sketchybar for space items.
# Click switches Space via the "Switch to Desktop N" shortcut (Ctrl+N).

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  # macOS key codes for digits 1-9
  KEY_CODES=(18 19 20 21 23 22 26 28 25)
  KEY_CODE=${KEY_CODES[$((SID - 1))]}
  [ -n "$KEY_CODE" ] && osascript -e "tell application \"System Events\" to key code $KEY_CODE using control down"
  exit 0
fi

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.color="$BLUE" icon.color="$BLACK"
else
  sketchybar --set "$NAME" background.color="$ITEM_BG" icon.color="$GREY"
fi
