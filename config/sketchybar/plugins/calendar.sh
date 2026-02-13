#!/bin/bash

# Calendar plugin with popup event list (similar to Raycast calendar).
# - Bar label: next upcoming event with time context
# - Popup: events for the next 3 days grouped by date
# - Click: toggles popup; "Open in Calendar" action at the top
#
# Uses compiled Swift binary (EventKit) for TCC-safe calendar access.

CALENDAR_BIN="$CONFIG_DIR/helpers/calendar_events"
POPUP_PARENT="calendar"
MAX_TITLE_LENGTH=40
DAYS_TO_FETCH=3
BAR_LOOKAHEAD=3600  # seconds — only show bar event if it starts within this window

# Colors (moonfly palette)
ACTIVE_COLOR=0xff80a0ff     # blue — current/upcoming event
PAST_COLOR=0xff6e6e6e       # grey — past events
ALLDAY_COLOR=0xff8cc85f     # green — all-day events
HEADER_COLOR=0xff9e9e9e     # light grey — day headers
NORMAL_COLOR=0xffbdbdbd     # default label color

if [ ! -x "$CALENDAR_BIN" ]; then
  sketchybar --set "$NAME" label="no binary"
  exit 0
fi

# Get events (lines after "-----" separator)
get_events() {
  "$CALENDAR_BIN" "$DAYS_TO_FETCH" 2>/dev/null | sed -n '/^-----$/,$ { /^-----$/d; p; }'
}

# Strip leading emoji and trailing whitespace from a title
strip_emoji() {
  echo "$1" | sed 's/^[^[:alnum:][:space:]]*[[:space:]]*//' | sed 's/[[:space:]]*$//'
}

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

update_bar_label() {
  # Show next upcoming (not past) event in the bar
  local events="$1"
  local now_epoch
  now_epoch=$(date +%s)

  if [ -z "$events" ]; then
    sketchybar --set "$NAME" label="No events"
    return
  fi

  # Find first upcoming or in-progress non-all-day event
  while IFS= read -r line; do
    [ -z "$line" ] && continue

    local time_part="${line%% |*}"
    local title
    title=$(strip_emoji "${line#* | }")
    local event_date="${time_part%% *}"
    local time_range="${time_part##* }"

    [ "$time_range" = "all-day" ] && continue

    local start_time="${time_range%%-*}"
    local end_time="${time_range##*-}"

    local start_epoch end_epoch
    start_epoch=$(date -j -f "%Y-%m-%d %H:%M" "$event_date $start_time" +%s 2>/dev/null)
    end_epoch=$(date -j -f "%Y-%m-%d %H:%M" "$event_date $end_time" +%s 2>/dev/null)

    # Handle events crossing midnight
    if [ -n "$end_epoch" ] && [ -n "$start_epoch" ] && [ "$end_epoch" -le "$start_epoch" ]; then
      end_epoch=$(( end_epoch + 86400 ))
    fi

    # Skip past events
    [ -n "$end_epoch" ] && [ "$end_epoch" -le "$now_epoch" ] && continue

    # Skip events starting more than BAR_LOOKAHEAD seconds from now
    [ -n "$start_epoch" ] && [ "$start_epoch" -gt "$now_epoch" ] && \
      [ $(( start_epoch - now_epoch )) -gt $BAR_LOOKAHEAD ] && continue

    # Truncate title
    if [ ${#title} -gt $MAX_TITLE_LENGTH ]; then
      title="${title:0:$MAX_TITLE_LENGTH}..."
    fi

    if [ -n "$start_epoch" ] && [ "$start_epoch" -gt "$now_epoch" ]; then
      local time_info
      time_info="in $(format_duration $(( start_epoch - now_epoch )) "")"
      sketchybar --set "$NAME" label="$title · $time_info"
    elif [ -n "$end_epoch" ] && [ "$end_epoch" -gt "$now_epoch" ]; then
      local time_info
      time_info="$(format_duration $(( end_epoch - now_epoch )) "left")"
      sketchybar --set "$NAME" label="$title · $time_info"
    else
      sketchybar --set "$NAME" label="$title"
    fi
    return
  done <<< "$events"

  # No upcoming timed events found — check for all-day events
  local first_allday
  first_allday=$(echo "$events" | grep "all-day" | head -1)
  if [ -n "$first_allday" ]; then
    local title
    title=$(strip_emoji "${first_allday#* | }")
    if [ ${#title} -gt $MAX_TITLE_LENGTH ]; then
      title="${title:0:$MAX_TITLE_LENGTH}..."
    fi
    sketchybar --set "$NAME" label="$title"
  else
    sketchybar --set "$NAME" label="No events"
  fi
}

update_popup() {
  # Remove old popup items
  EXISTING=$(sketchybar --query "$POPUP_PARENT" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    items = d.get('popup', {}).get('items', [])
    print(' '.join(items))
except:
    pass
" 2>/dev/null)

  for item in $EXISTING; do
    sketchybar --remove "$item" 2>/dev/null
  done

  local events
  events=$(get_events)
  local now_epoch
  now_epoch=$(date +%s)
  local item_idx=0

  # "Open in Calendar" action at the top
  sketchybar --add item "$POPUP_PARENT.open" popup."$POPUP_PARENT" \
             --set "$POPUP_PARENT.open"                             \
                   label="Open in Calendar"                         \
                   label.font="JetBrainsMono Nerd Font:Medium:13.0" \
                   label.color="$NORMAL_COLOR"                      \
                   icon="📅"                                        \
                   icon.padding_left=8                              \
                   label.padding_right=10                           \
                   click_script="open -a Calendar && sketchybar --set $POPUP_PARENT popup.drawing=off"

  if [ -z "$events" ]; then
    sketchybar --add item "$POPUP_PARENT.empty" popup."$POPUP_PARENT" \
               --set "$POPUP_PARENT.empty"                             \
                     label="No upcoming events"                        \
                     label.font="JetBrainsMono Nerd Font:Medium:13.0"  \
                     label.color="$PAST_COLOR"                         \
                     icon.drawing=off                                  \
                     label.padding_left=10                             \
                     label.padding_right=10
    return
  fi

  local current_day=""

  while IFS= read -r line; do
    [ -z "$line" ] && continue

    local time_part="${line%% |*}"
    local title
    title=$(strip_emoji "${line#* | }")
    local event_date="${time_part%% *}"
    local time_range="${time_part##* }"

    # Day header — group by date
    if [ "$event_date" != "$current_day" ]; then
      current_day="$event_date"

      # Format day header: "Today, Feb 12" / "Tomorrow, Feb 13" / "Saturday, Feb 14"
      local today tomorrow
      today=$(date +%Y-%m-%d)
      tomorrow=$(date -j -v+1d +%Y-%m-%d)

      local day_label
      if [ "$event_date" = "$today" ]; then
        day_label="Today, $(date -j -f "%Y-%m-%d" "$event_date" "+%b %-d")"
      elif [ "$event_date" = "$tomorrow" ]; then
        day_label="Tomorrow, $(date -j -f "%Y-%m-%d" "$event_date" "+%b %-d")"
      else
        day_label="$(date -j -f "%Y-%m-%d" "$event_date" "+%A, %b %-d")"
      fi

      local header_name="$POPUP_PARENT.hdr.$item_idx"
      sketchybar --add item "$header_name" popup."$POPUP_PARENT" \
                 --set "$header_name"                              \
                       label="$day_label"                          \
                       label.font="JetBrainsMono Nerd Font:Bold:12.0" \
                       label.color="$HEADER_COLOR"                 \
                       icon.drawing=off                            \
                       label.padding_left=10                       \
                       label.padding_right=10                      \
                       click_script="sketchybar --set $POPUP_PARENT popup.drawing=off"
      item_idx=$((item_idx + 1))
    fi

    # Truncate title
    if [ ${#title} -gt $MAX_TITLE_LENGTH ]; then
      title="${title:0:$MAX_TITLE_LENGTH}..."
    fi

    # Determine event state and colors
    local icon icon_color label_color display_label

    if [ "$time_range" = "all-day" ]; then
      icon="●"
      icon_color="$ALLDAY_COLOR"
      label_color="$NORMAL_COLOR"
      display_label="All day:  $title"
    else
      local start_time="${time_range%%-*}"
      local end_time="${time_range##*-}"
      local start_epoch end_epoch
      start_epoch=$(date -j -f "%Y-%m-%d %H:%M" "$event_date $start_time" +%s 2>/dev/null)
      end_epoch=$(date -j -f "%Y-%m-%d %H:%M" "$event_date $end_time" +%s 2>/dev/null)

      # Handle midnight crossing
      if [ -n "$end_epoch" ] && [ -n "$start_epoch" ] && [ "$end_epoch" -le "$start_epoch" ]; then
        end_epoch=$(( end_epoch + 86400 ))
      fi

      display_label="$start_time - $end_time   $title"

      if [ -n "$end_epoch" ] && [ "$end_epoch" -le "$now_epoch" ]; then
        # Past event
        icon="○"
        icon_color="$PAST_COLOR"
        label_color="$PAST_COLOR"
      elif [ -n "$start_epoch" ] && [ "$start_epoch" -le "$now_epoch" ]; then
        # In progress — bold style via color
        icon="●"
        icon_color="$ACTIVE_COLOR"
        label_color=0xffffffff
      else
        # Upcoming
        icon="○"
        icon_color="$ACTIVE_COLOR"
        label_color="$NORMAL_COLOR"
      fi
    fi

    local item_name="$POPUP_PARENT.evt.$item_idx"
    sketchybar --add item "$item_name" popup."$POPUP_PARENT"       \
               --set "$item_name"                                   \
                     label="$display_label"                         \
                     label.font="JetBrainsMono Nerd Font:Medium:13.0" \
                     label.color="$label_color"                     \
                     icon="$icon"                                   \
                     icon.color="$icon_color"                       \
                     icon.padding_left=8                            \
                     label.padding_right=10                         \
                     click_script="sketchybar --set $POPUP_PARENT popup.drawing=off"
    item_idx=$((item_idx + 1))

  done <<< "$events"
}

case "$SENDER" in
  mouse.clicked)
    update_popup
    sketchybar --set "$NAME" popup.drawing=toggle
    ;;
  mouse.exited|mouse.exited.global|front_app_switched)
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  *)
    EVENTS=$(get_events)
    update_bar_label "$EVENTS"
    ;;
esac
