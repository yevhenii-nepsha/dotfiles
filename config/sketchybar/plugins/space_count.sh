#!/bin/bash
# Print the number of native Spaces on the main display (desktops + fullscreen apps).

defaults export com.apple.spaces - \
  | plutil -convert json -o - - \
  | jq '[.SpacesDisplayConfiguration["Management Data"].Monitors[]
         | select(.Spaces != null) | .Spaces | length] | first // 1'
