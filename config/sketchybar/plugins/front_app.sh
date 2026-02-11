#!/bin/bash

# The front_app_switched event sends the name of the newly focused application
# in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
