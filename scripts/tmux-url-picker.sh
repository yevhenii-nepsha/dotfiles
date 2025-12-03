#!/usr/bin/env bash
# ============================================================================
# Tmux URL Picker with Context
# ============================================================================
# Fast URL extraction with context display
# Shows: context │ url

HISTORY_LIMIT="${1:-2000}"

# Check dependencies
if ! command -v fzf &>/dev/null; then
    tmux display-message "Error: fzf not installed"
    exit 1
fi

# Capture pane content
if [[ "$HISTORY_LIMIT" == "screen" ]]; then
    content="$(tmux capture-pane -J -p)"
else
    content="$(tmux capture-pane -J -p -S -"$HISTORY_LIMIT")"
fi

# Temporary file for results
tmp_file=$(mktemp)
trap "rm -f $tmp_file" EXIT

# 1. Extract markdown links: [text](url)
grep -oE '\[[^]]+\]\(<?https?://[^)>]+>?\)' <<< "$content" 2>/dev/null | while IFS= read -r match; do
    text="${match%%\]*}"
    text="${text#\[}"
    url="${match##*\(}"
    url="${url%\)}"
    url="${url#<}"
    url="${url%>}"
    [[ ${#text} -gt 50 ]] && text="${text:0:47}..."
    printf '%s │ %s\n' "$text" "$url"
done >> "$tmp_file"

# 2. Extract plain URLs with domain as context
grep -oE 'https?://[A-Za-z0-9._~:/?#@!$&()*+,;=%-]+' <<< "$content" 2>/dev/null | while IFS= read -r url; do
    # Clean trailing punctuation that may be captured from markdown
    url="${url%)}"
    url="${url%>}"
    domain="${url#*://}"
    domain="${domain%%/*}"
    printf '%s │ %s\n' "$domain" "$url"
done >> "$tmp_file"

# 3. Git SSH URLs
grep -oE 'git@[^:]+:[^ ]+' <<< "$content" 2>/dev/null | while IFS= read -r git_url; do
    # Convert git@github.com:user/repo to https://github.com/user/repo
    host="${git_url#git@}"
    host="${host%%:*}"
    path="${git_url#*:}"
    url="https://${host}/${path}"
    printf 'git │ %s\n' "$url"
done >> "$tmp_file"

# Remove duplicates by URL (second column), keep first occurrence
awk -F ' │ ' '!seen[$2]++' "$tmp_file" > "${tmp_file}.dedup"
mv "${tmp_file}.dedup" "$tmp_file"

# Check if any URLs found
if [[ ! -s "$tmp_file" ]]; then
    tmux display-message "No URLs found"
    exit 0
fi

url_count=$(wc -l < "$tmp_file" | tr -d ' ')

# Select with fzf (--nth 1 searches only in context column)
selected=$(fzf --tmux center,80%,50% \
    --header "Select URL ($url_count found):" \
    --multi \
    --no-preview \
    --bind 'ctrl-a:select-all' \
    --delimiter ' │ ' \
    --nth 1 < "$tmp_file") || true

# Open selected URLs
if [[ -n "$selected" ]]; then
    while IFS= read -r line; do
        url="${line##* │ }"
        if command -v open &>/dev/null; then
            open "$url" &>/dev/null &
        elif command -v xdg-open &>/dev/null; then
            xdg-open "$url" &>/dev/null &
        fi
    done <<< "$selected"
    
    # Show notification
    count=$(wc -l <<< "$selected" | tr -d ' ')
    if [[ "$count" -eq 1 ]]; then
        url="${selected##* │ }"
        display="${url:0:50}"
        [[ ${#url} -gt 50 ]] && display="${display}..."
        tmux display-message "Opening: $display"
    else
        tmux display-message "Opening $count URLs"
    fi
fi
