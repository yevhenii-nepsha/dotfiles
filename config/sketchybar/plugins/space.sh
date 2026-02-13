#!/bin/bash

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.color=0xff80a0ff
else
  sketchybar --set "$NAME" icon.color=0xffc6c6c6
fi
