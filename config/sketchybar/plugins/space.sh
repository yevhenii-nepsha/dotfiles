#!/bin/bash

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on          \
                           background.color=0xff80a0ff     \
                           icon.highlight=on
else
  sketchybar --set "$NAME" background.drawing=off          \
                           background.color=0x40323437     \
                           icon.highlight=off
fi
