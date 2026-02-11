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
EVENT_TIME=$(echo "$FIRST_EVENT" | sed 's/ |.*//' | awk '{print $2}' | cut -d'-' -f1)
EVENT_DATE=$(echo "$FIRST_EVENT" | awk '{print $1}')
EVENT_TITLE=$(echo "$FIRST_EVENT" | sed 's/.*| //')

# Truncate title if too long
if [ ${#EVENT_TITLE} -gt $MAX_TITLE_LENGTH ]; then
  EVENT_TITLE="${EVENT_TITLE:0:$MAX_TITLE_LENGTH}..."
fi

# Calculate time remaining
NOW_EPOCH=$(date +%s)
EVENT_EPOCH=$(date -j -f "%Y-%m-%d %H:%M" "$EVENT_DATE $EVENT_TIME" +%s 2>/dev/null)

if [ -z "$EVENT_EPOCH" ]; then
  REMAINING=""
elif [ "$EVENT_EPOCH" -le "$NOW_EPOCH" ]; then
  # Event is happening now
  REMAINING="now"
else
  DIFF=$(( EVENT_EPOCH - NOW_EPOCH ))
  HOURS=$(( DIFF / 3600 ))
  MINS=$(( (DIFF % 3600) / 60 ))

  if [ "$HOURS" -gt 0 ]; then
    REMAINING="in ${HOURS}h ${MINS}m"
  else
    REMAINING="in ${MINS}m"
  fi
fi

if [ -n "$REMAINING" ]; then
  LABEL="$EVENT_TITLE · $REMAINING"
else
  LABEL="$EVENT_TITLE · $EVENT_TIME"
fi

sketchybar --set "$NAME" label="$LABEL"
