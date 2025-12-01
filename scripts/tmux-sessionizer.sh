#!/usr/bin/env bash
# ============================================================================
# Tmux Sessionizer
# ============================================================================
# Find directories with fzf and create/switch to tmux session
#
# Usage: tmux-sessionizer.sh [depth]
#   depth: search depth (default: 2)

# Configuration
SEARCH_DIRS=(
    "$HOME/.dotfiles"
    "$HOME/Developer"
    "/Volumes/archive"
    "$HOME/Downloads"
)
DEFAULT_DEPTH=2

# Get depth from argument or use default
DEPTH="${1:-$DEFAULT_DEPTH}"

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    tmux display-message "❌ Error: fzf not installed"
    exit 1
fi

# Build find command for existing directories only
FIND_ARGS=()
for dir in "${SEARCH_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        FIND_ARGS+=("$dir")
    fi
done

# Exit if no directories found
if [[ ${#FIND_ARGS[@]} -eq 0 ]]; then
    tmux display-message "❌ Error: No search directories found"
    exit 1
fi

# Find directories and select with fzf
SELECTED=$(find "${FIND_ARGS[@]}" -mindepth 1 -maxdepth "$DEPTH" -type d 2>/dev/null | \
    fzf --prompt="Select project: " \
        --header="Search depth: $DEPTH | Esc to cancel" \
        --color="bg+:238,fg+:81,hl:81,hl+:81,header:250,pointer:81,marker:81,prompt:81,info:244" \
        --preview='ls -la {}' \
        --preview-window=right:40%:wrap)

# Exit if nothing selected
if [[ -z "$SELECTED" ]]; then
    exit 0
fi

# Generate session name from directory
# Replace dots and slashes with underscores, remove leading underscores
SESSION_NAME=$(basename "$SELECTED" | tr '.' '_')

# Check if session exists
if tmux has-session -t="$SESSION_NAME" 2>/dev/null; then
    # Switch to existing session
    tmux switch-client -t "$SESSION_NAME"
    tmux display-message "🔄 Switched to session '$SESSION_NAME'"
else
    # Create new session and switch to it
    tmux new-session -d -s "$SESSION_NAME" -c "$SELECTED"
    tmux switch-client -t "$SESSION_NAME"
    tmux display-message "✅ Session '$SESSION_NAME' created in $SELECTED"
fi
