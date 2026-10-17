#!/bin/bash
# Reload the bar when Spaces are added or removed, so the list stays in sync.

CURRENT=$("$CONFIG_DIR/plugins/space_count.sh")
DRAWN=$(sketchybar --query bar | jq '[.items[] | select(startswith("space."))] | length')

if [ "$CURRENT" != "$DRAWN" ]; then
  sketchybar --reload
fi
