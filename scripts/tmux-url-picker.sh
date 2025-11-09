#!/usr/bin/env bash
# ============================================================================
# Tmux URL Picker with Context
# ============================================================================
# Extracts URLs from current pane with surrounding context and opens selected

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    tmux display-message "❌ Error: fzf not installed"
    exit 1
fi

# Show loading indicator
tmux display-message "🔍 Scanning for URLs..."

# Capture pane content (last 1000 lines only for performance)
# -S -1000 means start from 1000 lines back in history
# This is much faster than -S - (entire history) for long sessions
PANE_CONTENT=$(tmux capture-pane -p -J -S -1000)

# Temporary file for URL list with context
TMP_FILE=$(mktemp)
trap "rm -f $TMP_FILE" EXIT

# Extract markdown links: [text](url) or [text](<url>)
# Process each line separately to handle multiple links per line
echo "$PANE_CONTENT" | while IFS= read -r line; do
    # Find all markdown links in the line
    # Use grep to extract each link, then process with sed
    echo "$line" | grep -oE '\[[^]]+\]\(<?https?://[^)>]+>?\)' | while read -r match; do
        # Extract text between [ and ]
        text=$(echo "$match" | sed -E 's/^\[([^]]+)\].*/\1/')

        # Extract URL (remove angle brackets if present)
        url=$(echo "$match" | sed -E 's/.*\(<?([^)>]+)>?\)/\1/')

        # Remove any remaining < or > from URL
        url=$(echo "$url" | tr -d '<>')

        # Truncate text if too long (keep it compact)
        if [ ${#text} -gt 40 ]; then
            text="${text:0:37}..."
        fi

        echo "${text} │ ${url}"
    done
done >> "$TMP_FILE"

# Extract plain URLs with context (only from lines without markdown links)
echo "$PANE_CONTENT" | grep -v '\[.*\](.*https\?://' | while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Find all URLs in the line
    echo "$line" | grep -oE 'https?://[a-zA-Z0-9./?=_%:~#+&@!-]+' | while read -r url; do
        # Get context before URL (last 30 chars before URL)
        before=$(echo "$line" | sed "s|$url.*||" | tail -c 31 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Get context after URL (first 15 chars after URL)
        after=$(echo "$line" | sed "s|.*$url||" | head -c 16 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Build context - use only before OR domain
        if [ -n "$before" ]; then
            context="$before"
        elif [ -n "$after" ]; then
            context="$after"
        else
            # No context - use domain name
            context=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|')
        fi

        # Truncate context if too long (compact)
        if [ ${#context} -gt 35 ]; then
            context="${context:0:32}..."
        fi

        echo "${context} │ ${url}"
    done
done >> "$TMP_FILE"

# Check if any URLs found BEFORE sorting
if [ ! -s "$TMP_FILE" ]; then
    tmux display-message "ℹ️  No URLs found in last 1000 lines"
    exit 0
fi

# Remove duplicates (same URL) - sort by URL (everything after │)
sort -u -t'│' -k2 "$TMP_FILE" 2>/dev/null > "${TMP_FILE}.sorted" || \
    sort -u "$TMP_FILE" > "${TMP_FILE}.sorted"
mv "${TMP_FILE}.sorted" "$TMP_FILE"

# Double-check after deduplication
if [ ! -s "$TMP_FILE" ]; then
    tmux display-message "ℹ️  No URLs found in last 1000 lines"
    exit 0
fi

# Count URLs
URL_COUNT=$(wc -l < "$TMP_FILE" | tr -d ' ')

# Clear loading message
tmux display-message ""

# Select URL with fzf (showing context | url)
# Full line format: "context │ url" - display both to see full URL
SELECTED=$(cat "$TMP_FILE" | fzf --reverse \
    --header "Select URL to open ($URL_COUNT found):" \
    --bind 'j:down,k:up,enter:accept' \
    --no-sort \
    --color='bg+:238,fg+:81,hl:81,hl+:81,header:250,pointer:81,marker:81,prompt:81,info:244')

# Extract URL from selection (everything after │)
if [ -n "$SELECTED" ]; then
    URL=$(echo "$SELECTED" | sed 's/.*│ //')

    # Use 'open' on macOS, 'xdg-open' on Linux
    if command -v open &> /dev/null; then
        open "$URL" &> /dev/null
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$URL" &> /dev/null
    else
        tmux display-message "❌ Error: No browser opener found (open/xdg-open)"
        exit 1
    fi

    # Show notification with truncated URL
    URL_DISPLAY="${URL:0:50}"
    [ ${#URL} -gt 50 ] && URL_DISPLAY="${URL_DISPLAY}..."
    tmux display-message "🌐 Opening: $URL_DISPLAY"
fi
