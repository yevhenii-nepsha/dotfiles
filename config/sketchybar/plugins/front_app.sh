#!/bin/bash

# The front_app_switched event sends the name of the newly focused application
# in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events

source "$CONFIG_DIR/plugins/icon_map.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  __icon_map "$INFO"
  sketchybar --set "$NAME" icon="$icon_result"          \
             --set front_app.name label="$INFO"
fi
