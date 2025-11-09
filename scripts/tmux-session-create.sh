#!/usr/bin/env bash
# ============================================================================
# Tmux New Session Creator
# ============================================================================
# Interactive session name input with fzf

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    tmux display-message "❌ Error: fzf not installed"
    exit 1
fi

# Get session name via fzf input
SESSION_NAME=$(echo "" | fzf --print-query \
    --prompt="New session name: " \
    --header="(Enter name, Esc to cancel)" \
    --color="bg+:238,fg+:81,hl:81,hl+:81,header:250,pointer:81,marker:81,prompt:81,info:244" \
    | head -1)

# Create and switch to new session if name provided
if [ -n "$SESSION_NAME" ]; then
    tmux new-session -d -s "$SESSION_NAME"
    tmux switch-client -t "$SESSION_NAME"
    tmux display-message "✅ Session '$SESSION_NAME' created"
fi
