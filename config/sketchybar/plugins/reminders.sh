#!/bin/bash

# Reminders plugin with popup menu.
# - Regular update: shows count in the bar, rebuilds popup items
# - Click (mouse.clicked): toggles the popup open/closed
# - Popup item click: completes the reminder and refreshes
#
# Uses compiled Swift binary (EventKit) — does not block Reminders.app UI.

REMINDER_BIN="$CONFIG_DIR/helpers/reminder_count"
POPUP_PARENT="reminders"
MAX_TITLE_LENGTH=40

if [ ! -x "$REMINDER_BIN" ]; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

OVERDUE_COLOR=0xffe33400      # moonfly red — overdue reminders
NORMAL_ICON_COLOR=0xff80a0ff  # moonfly blue — normal reminders

# Convert number to Unicode superscript
to_superscript() {
  echo "$1" | tr '0123456789' '⁰¹²³⁴⁵⁶⁷⁸⁹'
}

update_reminders() {
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

  # Fetch reminder list (JSON with hasTime, overdue flags)
  LIST=$("$REMINDER_BIN" list 2>/dev/null)

  if [ -z "$LIST" ] || [ "$LIST" = "[]" ]; then
    sketchybar --set "$POPUP_PARENT" label="" \
                                     icon="󰂜"  \
                                     icon.color="$NORMAL_ICON_COLOR"
    sketchybar --add item reminders.empty popup."$POPUP_PARENT" \
               --set reminders.empty label="No reminders due" \
                     icon.drawing=off \
                     click_script="sketchybar --set $POPUP_PARENT popup.drawing=off"
    return
  fi

  # Determine bar label: nearest timed reminder or count with overdue coloring
  BAR_INFO=$(echo "$LIST" | python3 -c "
import sys, json, re
from datetime import datetime

def strip_emoji(text):
    return re.sub(r'^[^\w\s]+\s*', '', text, flags=re.UNICODE).strip()

items = json.load(sys.stdin)
now = datetime.now()
count = len(items)
has_overdue = any(item.get('overdue', False) for item in items)

# Find nearest upcoming timed reminder
nearest_timed = None
nearest_diff = None
for item in items:
    if not item.get('hasTime', False) or item.get('overdue', False):
        continue
    due = item.get('due', '')
    if not due:
        continue
    try:
        due_time = datetime.strptime(due, '%H:%M').replace(
            year=now.year, month=now.month, day=now.day)
        # If due time is earlier than now, it might be tomorrow
        diff = (due_time - now).total_seconds()
        if diff < 0:
            diff += 86400
        if nearest_diff is None or diff < nearest_diff:
            nearest_diff = diff
            nearest_timed = item
    except ValueError:
        continue

if nearest_timed and nearest_diff is not None:
    title = strip_emoji(nearest_timed.get('title', ''))
    if len(title) > $MAX_TITLE_LENGTH:
        title = title[:$MAX_TITLE_LENGTH] + '...'
    hours = int(nearest_diff // 3600)
    mins = int((nearest_diff % 3600) // 60)
    if hours > 0:
        time_str = f'in {hours}h {mins}m'
    elif mins > 0:
        time_str = f'in {mins}m'
    else:
        time_str = 'in <1m'
    print(f'LABEL={title} · {time_str}')
    print(f'COUNT={count}')
    print(f'OVERDUE=false')
else:
    # No timed reminders — show count only in icon badge, label is empty
    print(f'LABEL=')
    print(f'COUNT={count}')
    if has_overdue:
        print(f'OVERDUE=true')
    else:
        print(f'OVERDUE=false')
")

  BAR_LABEL=$(echo "$BAR_INFO" | grep '^LABEL=' | cut -d= -f2-)
  BAR_COUNT=$(echo "$BAR_INFO" | grep '^COUNT=' | cut -d= -f2-)
  BAR_OVERDUE=$(echo "$BAR_INFO" | grep '^OVERDUE=' | cut -d= -f2-)

  # Build icon with superscript badge: "󰂜⁵" or just "󰂜"
  if [ -n "$BAR_COUNT" ] && [ "$BAR_COUNT" -gt 0 ] 2>/dev/null; then
    ICON_TEXT="󰂜$(to_superscript "$BAR_COUNT")"
  else
    ICON_TEXT="󰂜"
  fi

  if [ "$BAR_OVERDUE" = "true" ]; then
    sketchybar --set "$POPUP_PARENT" label="$BAR_LABEL" \
                                     icon="$ICON_TEXT"   \
                                     icon.color="$OVERDUE_COLOR" \
                                     label.color="$OVERDUE_COLOR"
  else
    sketchybar --set "$POPUP_PARENT" label="$BAR_LABEL" \
                                     icon="$ICON_TEXT"   \
                                     icon.color="$NORMAL_ICON_COLOR" \
                                     label.color=0xffbdbdbd
  fi

  # Build popup items
  echo "$LIST" | python3 -c "
import sys, json, re

def strip_emoji(text):
    return re.sub(r'^[^\w\s]+\s*', '', text, flags=re.UNICODE).strip()

items = json.load(sys.stdin)
for i, item in enumerate(items):
    item_id = item['id']
    title = strip_emoji(item.get('title', '(no title)'))
    due = item.get('due', '')
    has_time = item.get('hasTime', False)
    overdue = item.get('overdue', False)

    # Truncate title
    if len(title) > $MAX_TITLE_LENGTH:
        title = title[:$MAX_TITLE_LENGTH] + '...'

    label = title
    if has_time and due:
        label = f'{due}  {title}'

    # Escape for shell
    label = label.replace('\"', '\\\\\"')
    item_id_escaped = item_id.replace('\"', '\\\\\"')

    print(f'ITEM_NAME=\"reminders.item.{i}\"')
    print(f'ITEM_LABEL=\"{label}\"')
    print(f'ITEM_ID=\"{item_id_escaped}\"')
    print(f'ITEM_OVERDUE={\"true\" if overdue else \"false\"}')
    print(f'---')
" | while IFS= read -r line; do
    if [ "$line" = "---" ]; then
      if [ -n "$ITEM_NAME" ]; then
        if [ "$ITEM_OVERDUE" = "true" ]; then
          ICON_CLR="$OVERDUE_COLOR"
        else
          ICON_CLR="$NORMAL_ICON_COLOR"
        fi
        sketchybar --add item "$ITEM_NAME" popup."$POPUP_PARENT"       \
                   --set "$ITEM_NAME"                                   \
                         label="$ITEM_LABEL"                            \
                         label.font="JetBrainsMono Nerd Font:Medium:13.0" \
                         icon="○"                                       \
                         icon.padding_left=8                            \
                         icon.color="$ICON_CLR"                         \
                         label.padding_right=8                          \
                         click_script="$REMINDER_BIN complete '$ITEM_ID' && sketchybar --set $POPUP_PARENT popup.drawing=off && sketchybar --trigger reminders_refresh"
      fi
      ITEM_NAME=""
      ITEM_LABEL=""
      ITEM_ID=""
      ITEM_OVERDUE=""
    else
      eval "$line"
    fi
  done
}

case "$SENDER" in
  mouse.clicked)
    sketchybar --set "$NAME" popup.drawing=toggle
    ;;
  mouse.exited|mouse.exited.global|front_app_switched)
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  reminders_refresh|routine|forced)
    update_reminders
    ;;
  *)
    update_reminders
    ;;
esac
