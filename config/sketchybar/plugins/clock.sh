#!/bin/bash
# Show date and time, e.g. "Sat 17 Oct  13:49".

sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"
