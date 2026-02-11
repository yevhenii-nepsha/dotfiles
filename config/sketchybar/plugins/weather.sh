#!/bin/bash

# Weather plugin using wttr.in API.
# Shows temperature and short description for a hardcoded city.
# Updates every 30 minutes and on system wake.

CITY="Kyiv"
MAX_DESC_LENGTH=25

# Nerd Font weather icons (Unicode escape for reliable encoding)
ICON_SUNNY=""          # nf-weather-day_sunny
ICON_CLOUDY=""         # nf-weather-cloudy
ICON_PARTLY=""         # nf-weather-day_cloudy
ICON_FOG=""            # nf-weather-fog
ICON_RAIN=""           # nf-weather-rain
ICON_HEAVY_RAIN=""     # nf-weather-rain
ICON_SNOW=""           # nf-weather-snow
ICON_HEAVY_SNOW=""     # nf-weather-snow
ICON_SLEET=""          # nf-weather-sleet
ICON_THUNDER=""        # nf-weather-thunderstorm
ICON_FALLBACK=""       # nf-weather-na

WEATHER_JSON=$(curl -s --max-time 10 "wttr.in/${CITY}?format=j1" 2>/dev/null)

if [ -z "$WEATHER_JSON" ] || ! echo "$WEATHER_JSON" | jq -e . > /dev/null 2>&1; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

TEMP=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].temp_C')
DESC=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherDesc[0].value')
WEATHER_CODE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherCode')

# Truncate description if too long
if [ ${#DESC} -gt $MAX_DESC_LENGTH ]; then
  DESC="${DESC:0:$MAX_DESC_LENGTH}…"
fi

# Map weather code to icon
# https://www.worldweatheronline.com/developer/api/docs/weather-icons.aspx
case "$WEATHER_CODE" in
  113) ICON="$ICON_SUNNY" ;;
  116) ICON="$ICON_PARTLY" ;;
  119|122) ICON="$ICON_CLOUDY" ;;
  143|248|260) ICON="$ICON_FOG" ;;
  176|263|266|293|296) ICON="$ICON_RAIN" ;;
  299|302|305|308|356|359) ICON="$ICON_HEAVY_RAIN" ;;
  179|227|323|326) ICON="$ICON_SNOW" ;;
  230|329|332|335|338|368|371) ICON="$ICON_HEAVY_SNOW" ;;
  185|281|284|311|314|317|350|377) ICON="$ICON_SLEET" ;;
  200|386|389|392|395) ICON="$ICON_THUNDER" ;;
  *) ICON="$ICON_FALLBACK" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="${TEMP}° ${DESC}"
