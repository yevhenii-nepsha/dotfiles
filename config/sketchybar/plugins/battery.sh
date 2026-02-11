#!/bin/bash

# Battery plugin with Al Dente charge limiter detection.
# Al Dente holds the battery at a set percentage while on AC power,
# which pmset reports as "AC Power" + "not charging".

BATT_INFO="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATT_INFO" | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(echo "$BATT_INFO" | grep 'AC Power')"
NOT_CHARGING="$(echo "$BATT_INFO" | grep 'not charging')"

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

# Battery icon based on charge level
case "${PERCENTAGE}" in
  9[0-9]|100) ICON="" ;;
  [6-8][0-9]) ICON="" ;;
  [3-5][0-9]) ICON="" ;;
  [1-2][0-9]) ICON="" ;;
  *)          ICON="" ;;
esac

# Determine charging state
if [ -n "$CHARGING" ] && [ -n "$NOT_CHARGING" ]; then
  # AC connected but not charging = Al Dente charge limit active
  ICON=""
  LABEL="${PERCENTAGE}% 󰏤"
elif [ -n "$CHARGING" ]; then
  # Actively charging on AC
  ICON=""
  LABEL="${PERCENTAGE}%"
else
  # Running on battery
  LABEL="${PERCENTAGE}%"
fi

sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
