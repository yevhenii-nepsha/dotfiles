#!/usr/bin/env bash
# ============================================================================
# Tmux New Window Creator
# ============================================================================
# Interactive window name input with fzf

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    tmux display-message "❌ Error: fzf not installed"
    exit 1
fi

# Get current pane path for new window
CURRENT_PATH=$(tmux display-message -p "#{pane_current_path}")

# Get window name via fzf input
# Use process substitution to capture both output and exit code
set +e  # Don't exit on error
WINDOW_NAME=$(echo "" | fzf --print-query \
    --prompt="New window name: " \
    --header="(Enter for default, Esc to cancel)" \
    --color="bg+:238,fg+:81,hl:81,hl+:81,header:250,pointer:81,marker:81,prompt:81,info:244")
FZF_EXIT_CODE=$?
set -e

# Get first line only (user's input)
WINDOW_NAME=$(echo "$WINDOW_NAME" | head -1)

# Check if user cancelled (ESC pressed - exit code 130)
if [ $FZF_EXIT_CODE -eq 130 ]; then
    # User pressed ESC - cancel window creation
    tmux display-message "❌ Cancelled"
    exit 0
fi

# Create new window in current path
if [ -n "$WINDOW_NAME" ]; then
    # User provided name - create with custom name
    tmux new-window -c "$CURRENT_PATH" -n "$WINDOW_NAME"
    tmux display-message "✅ Window '$WINDOW_NAME' created"
else
    # User pressed Enter without text - create with default name
    tmux new-window -c "$CURRENT_PATH"
    tmux display-message "✅ New window created"
fi
