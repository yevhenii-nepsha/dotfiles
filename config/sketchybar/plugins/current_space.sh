#!/bin/bash
# Show active space: app icons for 1-4, Roman numerals for 5+.

APP_FONT="sketchybar-app-font:Regular:16.0"
TEXT_FONT="JetBrainsMono Nerd Font:Bold:17.0"

update_space() {
  SPACE_ID=$(echo "$INFO" | jq -r '."display-1"')

  if [ -z "$SPACE_ID" ] || [ "$SPACE_ID" = "null" ]; then
    SPACE_ID=1
  fi

  case "$SPACE_ID" in
    1) ICON=":firefox:";  FONT="$APP_FONT" ;;
    2) ICON=":kitty:";    FONT="$APP_FONT" ;;
    3) ICON=":obsidian:"; FONT="$APP_FONT" ;;
    4) ICON=":music:";    FONT="$APP_FONT" ;;
    5) ICON="V";     FONT="$TEXT_FONT" ;;
    6) ICON="VI";    FONT="$TEXT_FONT" ;;
    7) ICON="VII";   FONT="$TEXT_FONT" ;;
    8) ICON="VIII";  FONT="$TEXT_FONT" ;;
    9) ICON="IX";    FONT="$TEXT_FONT" ;;
    10) ICON="X";    FONT="$TEXT_FONT" ;;
    *)  ICON="$SPACE_ID"; FONT="$TEXT_FONT" ;;
  esac

  sketchybar --set "$NAME" icon="$ICON" icon.font="$FONT"
}

case "$SENDER" in
  "mouse.clicked")
    open -a "Mission Control"
    ;;
  *)
    update_space
    ;;
esac
