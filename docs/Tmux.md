# Tmux Configuration Guide

Complete guide to tmux configuration with session persistence and nested tmux support.

## Quick Start

Your tmux sessions automatically save and restore across computer restarts. Work in tmux as usual - sessions save every 15 minutes and restore on startup.

### Essential Commands

**Session Persistence:**
- **Manual Save**: `Ctrl+s Ctrl+s` - save current session immediately
- **Manual Restore**: `Ctrl+s Ctrl+r` - restore last saved session
- **Auto-save**: Happens every 15 minutes automatically
- **Auto-restore**: Happens when tmux starts

**Basic Operations:**
- **Reload Config**: `Ctrl+s r`
- **New Window**: `Ctrl+s c`
- **Split Horizontal**: `Ctrl+s \`
- **Split Vertical**: `Ctrl+s -`
- **Navigate Panes**: `Ctrl+h/j/k/l` (works with vim too!)

### How It Works

1. **On Login**: Shell auto-attaches to `main` session (configured in `~/.config/zsh/init.zsh`)
2. **While Working**: Session auto-saves every 15 minutes
3. **On Restart**: Session auto-restores with all windows, panes, and programs

### Quick Test

```bash
# 1. Create some windows and panes in tmux
# 2. Manually save
Ctrl+s Ctrl+s

# 3. Exit tmux completely
exit  # in all panes

# 4. Start new terminal
# Tmux auto-attaches to main and restores your layout
```

## Overview

This tmux configuration provides a modern, powerful setup with automatic session persistence, seamless vim integration, and nested tmux support for working on remote servers.

**Prefix Key**: `Ctrl+s` (instead of default `Ctrl+b`)

**File Structure:**

```
config/tmux/
├── tmux.conf           # Main tmux configuration
├── plugins/            # TPM and installed plugins
│   ├── tpm/            # Tmux Plugin Manager
│   ├── tmux-resurrect/ # Session save/restore plugin
│   ├── tmux-continuum/ # Automatic session management
│   ├── vim-tmux-navigator/ # Vim/tmux navigation
│   └── minimal-tmux-status/ # Status bar theme
└── resurrect/          # Saved session data
    ├── last            # Symlink to last saved session
    ├── pane_contents.tar.gz # Saved pane contents
    └── tmux_resurrect_*.txt # Session snapshots
```

## Features

- **Session Persistence**: Sessions automatically save and restore across computer restarts
- **Auto-save**: Sessions are automatically saved every 15 minutes
- **Auto-restore**: Sessions are restored when tmux starts
- **Pane Content Preservation**: The content of panes is saved and restored
- **Shell History**: Command history is preserved across restarts
- **Neovim Integration**: Neovim sessions are saved and restored
- **Seamless Vim Navigation**: Navigate between vim splits and tmux panes with same keys
- **Nested Tmux Support**: Automatic detection and configuration for remote sessions
- **Visual Indicators**: Color-coded status bars for nested sessions

## Keybindings

All commands use the prefix `Ctrl+s` (or `Ctrl+a` in nested tmux).

### Window Management

```
Ctrl+s c              - Create new window
Ctrl+s ,              - Rename current window
Ctrl+s &              - Kill current window
Ctrl+s n              - Next window
Ctrl+s p              - Previous window
Ctrl+s 0-9            - Switch to window by number
Ctrl+s w              - List all windows
```

### Pane Management

```
Ctrl+s \              - Split pane horizontally
Ctrl+s -              - Split pane vertically
Ctrl+s x              - Kill current pane
Ctrl+s z              - Toggle pane zoom (fullscreen)
Ctrl+s {              - Move pane left
Ctrl+s }              - Move pane right
Ctrl+s o              - Cycle through panes
```

### Pane Navigation

```
Ctrl+h                - Move to left pane (works with vim)
Ctrl+j                - Move to pane below (works with vim)
Ctrl+k                - Move to pane above (works with vim)
Ctrl+l                - Move to right pane (works with vim)
```

### Session Management

```
Ctrl+s d              - Detach from session
Ctrl+s s              - Session selector
Ctrl+s $              - Rename session
Ctrl+s (              - Previous session
Ctrl+s )              - Next session
```

### Session Persistence

```
Ctrl+s Ctrl+s         - Save session manually
Ctrl+s Ctrl+r         - Restore session manually
```

### Configuration

```
Ctrl+s r              - Reload tmux configuration
Ctrl+s ?              - List all key bindings
```

## Session Management

### Automatic Save/Restore

Sessions are automatically:
- **Saved** every 15 minutes while tmux is running
- **Restored** when tmux starts (via `@continuum-restore 'on'`)

### Manual Control

You can manually save or restore sessions anytime:
- **Save session**: `Ctrl+s Ctrl+s`
- **Restore session**: `Ctrl+s Ctrl+r`

### What Gets Saved?

- All tmux sessions and windows
- Window names and layouts
- Active pane in each window
- Working directory for each pane
- Running programs in each pane
- Pane contents (scrollback buffer)
- Shell command history
- Neovim sessions (when using nvim)

### Saved Session Location

All session data is stored in: `~/.config/tmux/resurrect/`

### Programs Configured to Restore

The following programs are configured to restore their state:
- `ssh` - SSH connections
- `psql` - PostgreSQL client
- `mysql` - MySQL client
- `sqlite3` - SQLite client
- `python` - Python interpreter
- `ipython` - IPython interpreter
- `vim` / `nvim` - Editors (default)

### Integration with Zsh

The dotfiles are configured to automatically attach to the `main` tmux session on shell startup (see `~/.config/zsh/init.zsh`).

This means:
1. When you open a terminal, it automatically attaches to the `main` session
2. If the `main` session doesn't exist, it creates it
3. The session state is automatically restored from last save
4. You can restart your computer and resume where you left off

### Verify It's Working

```bash
# Check if auto-save is running
tmux show-options -g | grep continuum-save-interval
# Should show: @continuum-save-interval 15

# Check last save time
tmux show-options -g | grep continuum-save-last-timestamp

# View saved sessions
ls -lah ~/.config/tmux/resurrect/
```

### Starting Fresh

```bash
# Delete all saved sessions
rm -rf ~/.config/tmux/resurrect/*
```

## Nested Tmux

This tmux configuration automatically detects when it's running inside another tmux session (nested) and adjusts the prefix key accordingly.

### How Nested Detection Works

The detection uses `TMUX_NESTED` environment variable, which is automatically set in two ways:

1. **SSH connection detection** (primary): If you connect via SSH, the system assumes you're in nested tmux and sets `TMUX_NESTED=1` automatically in `init.zsh`
2. **Zsh wrapper function** (fallback): When you manually run `tmux` inside existing tmux, the wrapper function sets `TMUX_NESTED=1`

### Prefix Keys by Level

**Outer tmux (local machine):**
- Prefix: `Ctrl+S`
- Status bar: Dark gray background
- All standard key bindings work
- `TMUX_NESTED` is not set
- No SSH connection detected

**Inner tmux (remote server via SSH):**
- Prefix: `Ctrl+A`
- Status bar: Dark red background (visual indicator)
- All standard key bindings work with Ctrl+A prefix
- `TMUX_NESTED=1` is automatically set when SSH connection is detected

### Visual Indicators

- **Dark gray status bar** = Outer tmux (local machine)
- **Dark red status bar** = Inner tmux (nested session, e.g., SSH)

This color coding helps you immediately know which tmux level you're controlling.

### Common Commands by Level

**Outer tmux (local):**
```
Ctrl+S c          - Create new window
Ctrl+S d          - Detach from session
Ctrl+S s          - Session selector
Ctrl+S \          - Split horizontal
Ctrl+S -          - Split vertical
```

**Inner tmux (remote):**
```
Ctrl+A c          - Create new window
Ctrl+A d          - Detach from session
Ctrl+A s          - Session selector
Ctrl+A \          - Split horizontal
Ctrl+A -          - Split vertical
```

### Sending Prefix Keys

If you need to send the prefix key to the outer tmux when inside nested:
- `Ctrl+S Ctrl+S` - Sends Ctrl+S to outer tmux

If you need to send prefix to inner tmux from outer:
- `Ctrl+S Ctrl+A` - Sends Ctrl+A to inner tmux

### Nested Tmux Tips

1. **Start nested tmux manually** on remote server:
   ```bash
   ssh server
   tmux  # The wrapper function will automatically set TMUX_NESTED=1
   ```

2. **Exit nested tmux** without closing SSH:
   ```
   Ctrl+A d  # Detach from inner tmux
   ```

3. **Use prefix+s** for session selector in both outer and inner tmux

4. **Check if you're in nested tmux:**
   ```bash
   echo $TMUX_NESTED  # Should be "1" in nested, empty in outer
   ```

5. **Quick reference card:**
   - Local machine: Think "**S**ystem" = Ctrl+**S**
   - Remote machine: Think "**A**way" = Ctrl+**A**

## Plugins

Plugins are managed by [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm).

### Installing/Updating Plugins

Run the setup script:

```bash
~/.dotfiles/scripts/setup-tmux-plugins.sh
```

Or use TPM directly:

```bash
# Install plugins
~/.config/tmux/plugins/tpm/bin/install_plugins

# Update plugins
~/.config/tmux/plugins/tpm/bin/update_plugins all
```

### Installed Plugins

1. **tmux-resurrect** - Core session persistence
   - Repository: https://github.com/tmux-plugins/tmux-resurrect
   - Provides manual save/restore functionality

2. **tmux-continuum** - Automatic session management
   - Repository: https://github.com/tmux-plugins/tmux-continuum
   - Provides automatic save/restore functionality

3. **vim-tmux-navigator** - Seamless vim/tmux navigation
   - Repository: https://github.com/christoomey/vim-tmux-navigator

4. **minimal-tmux-status** - Minimal status bar theme
   - Repository: https://github.com/niksingh710/minimal-tmux-status

## Troubleshooting

### Sessions Not Restoring

**Check if auto-restore is enabled:**
```bash
tmux show-options -g | grep continuum-restore
# Should show: @continuum-restore on
```

**Check if saves exist:**
```bash
ls -lah ~/.config/tmux/resurrect/
```

**Manually restore:**
```bash
# In tmux: Ctrl+s Ctrl+r
# Or run: ~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh
```

### Auto-save Not Working

**Check save interval:**
```bash
tmux show-options -g | grep continuum-save-interval
# Should show: @continuum-save-interval 15
```

**Check last save timestamp:**
```bash
tmux show-options -g | grep continuum-save-last-timestamp
```

**Manually trigger save:**
```bash
# In tmux: Ctrl+s Ctrl+s
# Or run: ~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh
```

### Pane Contents Not Saving

Check if pane content capture is enabled:
```bash
tmux show-options -g | grep resurrect-capture-pane-contents
# Should show: @resurrect-capture-pane-contents on
```

### Nested Tmux Prefix Issues

**Problem**: After reloading config, Ctrl+S doesn't work (only Ctrl+A works)

This happens if you reload tmux config while already inside tmux.

**Solution 1: Restart tmux (recommended)**
```bash
exit  # or Ctrl+A d (if you reloaded and have Ctrl+A)
tmux  # Start again - Ctrl+S should work correctly
```

**Solution 2: Quick fix without restarting**
```bash
tmux set -g prefix C-s
tmux bind C-s send-prefix
tmux set -g status-style "bg=colour235,fg=colour250"
```

## Configuration Customization

To modify session persistence settings, edit `~/.dotfiles/config/tmux/tmux.conf`:

```bash
# Change auto-save interval (default: 15 minutes)
set -g @continuum-save-interval '15'

# Disable auto-restore (if needed)
set -g @continuum-restore 'off'

# Add more programs to restore
set -g @resurrect-processes 'ssh psql mysql your-program'
```

After making changes, reload config:
```bash
tmux source-file ~/.config/tmux/tmux.conf
# Or in tmux: Ctrl+s r
```

## Additional Resources

- [tmux-resurrect documentation](https://github.com/tmux-plugins/tmux-resurrect/blob/master/docs/restoring_programs.md)
- [tmux-continuum documentation](https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/automatic_start.md)
- Main tmux config: `~/.config/tmux/tmux.conf`
- Zsh integration: `~/.config/zsh/init.zsh`
