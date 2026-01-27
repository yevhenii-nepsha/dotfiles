#!/usr/bin/env zsh

# Firefox Profile Setup
# Creates symlinks from Firefox profile to dotfiles

DOTFILES_DIR="${0:a:h}"
FIREFOX_CONFIG="$DOTFILES_DIR/config/firefox"

echo "🦊 Firefox Profile Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find Firefox profiles directory
FIREFOX_DIR="$HOME/Library/Application Support/Firefox/Profiles"
if [[ ! -d "$FIREFOX_DIR" ]]; then
    # Check alternative location (custom profiles)
    FIREFOX_DIR="$HOME/Documents/ff-profiles"
fi

# Find available profiles
profiles=()
if [[ -d "$FIREFOX_DIR" ]]; then
    for dir in "$FIREFOX_DIR"/*(/N); do
        profiles+=("$dir")
    done
fi

if [[ ${#profiles[@]} -eq 0 ]]; then
    echo "No Firefox profiles found automatically."
    echo ""
    read "profile_path?Enter Firefox profile path: "
else
    echo "Found Firefox profiles:"
    echo ""
    for i in {1..${#profiles[@]}}; do
        echo "  $i) ${profiles[$i]:t}"
    done
    echo ""
    echo "  0) Enter custom path"
    echo ""
    read "choice?Select profile (1-${#profiles[@]}, or 0 for custom): "
    
    if [[ "$choice" == "0" ]]; then
        read "profile_path?Enter Firefox profile path: "
    elif [[ "$choice" -ge 1 && "$choice" -le ${#profiles[@]} ]]; then
        profile_path="${profiles[$choice]}"
    else
        echo "❌ Invalid choice"
        exit 1
    fi
fi

# Validate profile path
if [[ ! -d "$profile_path" ]]; then
    echo "❌ Directory not found: $profile_path"
    exit 1
fi

echo ""
echo "📁 Profile: $profile_path"
echo ""

# Backup and symlink user.js
if [[ -f "$profile_path/user.js" && ! -L "$profile_path/user.js" ]]; then
    echo "📦 Backing up existing user.js"
    mv "$profile_path/user.js" "$profile_path/user.js.bak"
fi
ln -sf "$FIREFOX_CONFIG/user.js" "$profile_path/user.js"
echo "✅ Symlinked user.js"

# Backup and symlink chrome/
if [[ -d "$profile_path/chrome" && ! -L "$profile_path/chrome" ]]; then
    echo "📦 Backing up existing chrome/"
    mv "$profile_path/chrome" "$profile_path/chrome.bak"
fi
ln -sf "$FIREFOX_CONFIG/chrome" "$profile_path/chrome"
echo "✅ Symlinked chrome/"

# Copy containers.json (symlink may cause issues)
if [[ -f "$FIREFOX_CONFIG/containers.json" ]]; then
    cp "$FIREFOX_CONFIG/containers.json" "$profile_path/"
    echo "✅ Copied containers.json"
fi

# Copy handlers.json
if [[ -f "$FIREFOX_CONFIG/handlers.json" ]]; then
    cp "$FIREFOX_CONFIG/handlers.json" "$profile_path/"
    echo "✅ Copied handlers.json"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Firefox setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Firefox"
echo "  2. Install extensions from: $FIREFOX_CONFIG/extensions.txt"
echo ""
