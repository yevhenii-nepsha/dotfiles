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

update_reminders() {
  COUNT=$("$REMINDER_BIN" count 2>/dev/null)
  sketchybar --set "$POPUP_PARENT" label="${COUNT:-0}"

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

  # Build new popup items from reminder list
  LIST=$("$REMINDER_BIN" list 2>/dev/null)

  if [ -z "$LIST" ] || [ "$LIST" = "[]" ]; then
    sketchybar --add item reminders.empty popup."$POPUP_PARENT" \
               --set reminders.empty label="No reminders due" \
                     icon.drawing=off \
                     click_script="sketchybar --set $POPUP_PARENT popup.drawing=off"
    return
  fi

  # Parse JSON and create popup items
  echo "$LIST" | python3 -c "
import sys, json

items = json.load(sys.stdin)
for i, item in enumerate(items):
    item_id = item['id']
    title = item.get('title', '(no title)')
    due = item.get('due', '')

    # Truncate title
    if len(title) > $MAX_TITLE_LENGTH:
        title = title[:$MAX_TITLE_LENGTH] + '...'

    label = title
    if due:
        label = f'{due}  {title}'

    # Escape for shell
    label = label.replace('\"', '\\\\\"')
    item_id_escaped = item_id.replace('\"', '\\\\\"')

    print(f'ITEM_NAME=\"reminders.item.{i}\"')
    print(f'ITEM_LABEL=\"{label}\"')
    print(f'ITEM_ID=\"{item_id_escaped}\"')
    print(f'---')
" | while IFS= read -r line; do
    if [ "$line" = "---" ]; then
      if [ -n "$ITEM_NAME" ]; then
        sketchybar --add item "$ITEM_NAME" popup."$POPUP_PARENT"       \
                   --set "$ITEM_NAME"                                   \
                         label="$ITEM_LABEL"                            \
                         label.font="JetBrainsMono Nerd Font:Medium:13.0" \
                         icon="○"                                       \
                         icon.padding_left=8                            \
                         icon.color=0xff80a0ff                          \
                         label.padding_right=8                          \
                         click_script="$REMINDER_BIN complete '$ITEM_ID' && sketchybar --set $POPUP_PARENT popup.drawing=off && sketchybar --trigger reminders_refresh"
      fi
      ITEM_NAME=""
      ITEM_LABEL=""
      ITEM_ID=""
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
