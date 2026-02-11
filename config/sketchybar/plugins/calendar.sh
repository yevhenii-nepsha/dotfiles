#!/bin/bash

# Calendar plugin: shows the next upcoming event and time remaining.
# Uses compiled Swift binary (EventKit) for TCC-safe calendar access.

CALENDAR_BIN="$CONFIG_DIR/helpers/calendar_events"
MAX_TITLE_LENGTH=30

if [ ! -x "$CALENDAR_BIN" ]; then
  sketchybar --set "$NAME" label="no binary"
  exit 0
fi

# Get events for today (output lines after "-----" separator)
EVENTS=$("$CALENDAR_BIN" 1 2>/dev/null | sed -n '/^-----$/,$ { /^-----$/d; p; }')

if [ -z "$EVENTS" ]; then
  sketchybar --set "$NAME" label="No events"
  exit 0
fi

# Take the first event (nearest upcoming)
FIRST_EVENT=$(echo "$EVENTS" | head -1)

# Parse: "2026-02-11 09:00-10:00 | Meeting title"
EVENT_DATE=$(echo "$FIRST_EVENT" | awk '{print $1}')
EVENT_TIME_RANGE=$(echo "$FIRST_EVENT" | sed 's/ |.*//' | awk '{print $2}')
EVENT_START=$(echo "$EVENT_TIME_RANGE" | cut -d'-' -f1)
EVENT_END=$(echo "$EVENT_TIME_RANGE" | cut -d'-' -f2)
EVENT_TITLE=$(echo "$FIRST_EVENT" | sed 's/.*| //')

# Truncate title if too long
if [ ${#EVENT_TITLE} -gt $MAX_TITLE_LENGTH ]; then
  EVENT_TITLE="${EVENT_TITLE:0:$MAX_TITLE_LENGTH}..."
fi

# Calculate time context
NOW_EPOCH=$(date +%s)
START_EPOCH=$(date -j -f "%Y-%m-%d %H:%M" "$EVENT_DATE $EVENT_START" +%s 2>/dev/null)
END_EPOCH=$(date -j -f "%Y-%m-%d %H:%M" "$EVENT_DATE $EVENT_END" +%s 2>/dev/null)

# Handle events crossing midnight (e.g., 23:30-00:30)
if [ -n "$END_EPOCH" ] && [ -n "$START_EPOCH" ] && [ "$END_EPOCH" -le "$START_EPOCH" ]; then
  END_EPOCH=$(( END_EPOCH + 86400 ))
fi

format_duration() {
  local secs=$1 suffix=$2
  local hours=$(( secs / 3600 ))
  local mins=$(( (secs % 3600) / 60 ))

  if [ "$hours" -gt 0 ]; then
    echo "${hours}h ${mins}m $suffix"
  elif [ "$mins" -gt 0 ]; then
    echo "${mins}m $suffix"
  else
    echo "<1m $suffix"
  fi
}

if [ -n "$START_EPOCH" ] && [ "$START_EPOCH" -gt "$NOW_EPOCH" ]; then
  # Event hasn't started yet
  TIME_INFO=$(format_duration $(( START_EPOCH - NOW_EPOCH )) "")
  TIME_INFO="in $TIME_INFO"
elif [ -n "$END_EPOCH" ] && [ "$END_EPOCH" -gt "$NOW_EPOCH" ]; then
  # Event is in progress
  TIME_INFO=$(format_duration $(( END_EPOCH - NOW_EPOCH )) "left")
else
  TIME_INFO=""
fi

if [ -n "$TIME_INFO" ]; then
  LABEL="$EVENT_TITLE · $TIME_INFO"
else
  LABEL="$EVENT_TITLE"
fi

sketchybar --set "$NAME" label="$LABEL"
