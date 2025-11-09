#!/usr/bin/env bash
# ============================================================================
# Tmux Session Selector
# ============================================================================
# Interactive session selector with fzf and vim-style navigation

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    tmux display-message "❌ Error: fzf not installed"
    exit 1
fi

# Get current session to exclude it from list
CURRENT_SESSION=$(tmux display-message -p '#S')

# Select session with fzf
SELECTED=$(tmux list-sessions -F '#{session_name} (#{session_windows} windows)' \
    | grep -v "^$CURRENT_SESSION " \
    | fzf --reverse \
          --header 'Select session:' \
          --bind 'j:down,k:up,enter:accept' \
          --no-sort \
          --color='bg+:238,fg+:81,hl:81,hl+:81,header:250,pointer:81,marker:81,prompt:81,info:244' \
    | awk '{print $1}')

# Switch to selected session if not cancelled
[ -n "$SELECTED" ] && tmux switch-client -t "$SELECTED"
