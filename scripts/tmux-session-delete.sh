#!/usr/bin/env bash
# ============================================================================
# Tmux Session Deleter
# ============================================================================
# Interactive session deletion with fzf and confirmation

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    tmux display-message "❌ Error: fzf not installed"
    exit 1
fi

# Select session to delete with fzf (red theme for warning)
SESSION=$(tmux list-sessions -F '#{session_name} (#{session_windows} windows)' \
    | fzf --reverse \
          --header 'Delete session (Esc to cancel):' \
          --bind 'j:down,k:up,enter:accept' \
          --no-sort \
          --color='bg+:238,fg+:196,hl:196,hl+:196,header:250,pointer:196,marker:196,prompt:196,info:244' \
    | awk '{print $1}')

# Delete session if selected
if [ -n "$SESSION" ]; then
    tmux kill-session -t "$SESSION" 2>/dev/null \
        && tmux display-message "✅ Session '$SESSION' deleted" \
        || tmux display-message "❌ Error: Could not delete session '$SESSION'"
fi
