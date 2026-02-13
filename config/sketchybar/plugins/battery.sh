#!/bin/bash

# Battery plugin with Al Dente charge limiter detection and color-coded levels.
# Uses moonfly color palette and basic Unicode symbols for reliable rendering.

# Moonfly colors
COLOR_GREEN=0xff8cc85f
COLOR_YELLOW=0xffe3c78a
COLOR_RED=0xffff5d5d
COLOR_CRANBERRY=0xffff5189
COLOR_BLUE=0xff80a0ff
COLOR_LABEL=0xffbdbdbd

BATT_INFO="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATT_INFO" | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(echo "$BATT_INFO" | grep 'AC Power')"
NOT_CHARGING="$(echo "$BATT_INFO" | grep 'not charging')"

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

# Color based on charge level
case "${PERCENTAGE}" in
  [8-9][0-9]|100) COLOR="$COLOR_GREEN" ;;
  [6-7][0-9])     COLOR="$COLOR_YELLOW" ;;
  [3-5][0-9])     COLOR="$COLOR_YELLOW" ;;
  [1-2][0-9])     COLOR="$COLOR_RED" ;;
  *)              COLOR="$COLOR_CRANBERRY" ;;
esac

# Icon and label based on charging state
if [ -n "$CHARGING" ] && [ -n "$NOT_CHARGING" ]; then
  # AC connected but not charging = Al Dente charge limit active
  ICON="▪"
  COLOR="$COLOR_BLUE"
  LABEL="${PERCENTAGE}%"
elif [ -n "$CHARGING" ]; then
  # Actively charging on AC
  ICON="▲"
  COLOR="$COLOR_GREEN"
  LABEL="${PERCENTAGE}%"
else
  # Running on battery (discharging)
  ICON="▼"
  LABEL="${PERCENTAGE}%"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" \
                         label="$LABEL" label.color="$COLOR_LABEL"
