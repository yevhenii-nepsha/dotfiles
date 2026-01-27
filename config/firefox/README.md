# Firefox Profile Configuration

## Quick Setup

Run the setup script:

```bash
./setup_firefox.zsh
```

The script will:
1. Find available Firefox profiles
2. Let you select which profile to configure
3. Create symlinks and copy necessary files
4. Show next steps

## Manual Setup

If you prefer manual setup:

```bash
PROFILE_DIR="$HOME/Library/Application Support/Firefox/Profiles/XXXXXXXX.default-release"

# Symlink user.js (settings)
ln -sf ~/.dotfiles/config/firefox/user.js "$PROFILE_DIR/user.js"

# Symlink chrome directory (UI customization)
ln -sf ~/.dotfiles/config/firefox/chrome "$PROFILE_DIR/chrome"

# Copy containers (symlink may cause issues)
cp ~/.dotfiles/config/firefox/containers.json "$PROFILE_DIR/"
cp ~/.dotfiles/config/firefox/handlers.json "$PROFILE_DIR/"
```

Then restart Firefox.

## Files

| File | Description |
|------|-------------|
| `user.js` | Privacy settings, telemetry disable, UI prefs |
| `chrome/userChrome.css` | Custom UI styling (JetBrainsMono font) |
| `containers.json` | Container definitions (Personal, Work) |
| `handlers.json` | File type handlers |
| `extensions.txt` | List of recommended extensions |

## Notes

- `user.js` is read on startup and overrides `prefs.js`
- Changes in `about:config` may be overwritten by `user.js`
- Extensions should be installed via Firefox Sync or manually
