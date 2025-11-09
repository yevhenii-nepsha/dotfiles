#!/usr/bin/env bash
# ============================================================================
# Tmux Plugin Manager (TPM) and Plugins Setup
# ============================================================================
# This script ensures TPM is installed and plugins are installed/updated

set -e  # Exit on error

# TPM uses ~/.tmux/plugins by convention (matches tmux.conf line 181)
TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"
TPM_DIR="$TMUX_PLUGIN_DIR/tpm"
# Resurrect saves to separate location (configured in tmux.conf)
RESURRECT_DIR="$HOME/.config/tmux/resurrect"

echo "🔧 Setting up tmux plugins..."

# Create required directories
mkdir -p "$TMUX_PLUGIN_DIR"
mkdir -p "$RESURRECT_DIR"

# Install TPM if not present
if [ ! -d "$TPM_DIR" ]; then
    echo "📦 Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "✅ TPM installed successfully"
else
    echo "✅ TPM already installed"
    # Update TPM
    cd "$TPM_DIR"
    git pull --quiet origin master || echo "⚠️  Could not update TPM"
    cd - > /dev/null
fi

# Install/update plugins (works with or without tmux running)
echo "🔄 Installing/updating plugins..."

# Check if tmux is running
if tmux info &> /dev/null; then
    # Tmux is running - use TPM directly
    "$TPM_DIR/bin/install_plugins" || echo "⚠️  Some plugins may have failed to install"
    "$TPM_DIR/bin/update_plugins" all || echo "⚠️  Some plugins may have failed to update"
    echo "✅ Plugins installed/updated"
    echo "💡 Reload tmux config with: Ctrl+s r"
else
    # Tmux is not running - start headless session to install plugins
    echo "⚠️  Tmux is not running. Starting headless session for plugin install..."

    # Start tmux in detached mode, run plugin install, then kill session
    tmux new-session -d -s dotbot-install 2>/dev/null || true
    sleep 1  # Give tmux time to initialize

    # Run plugin installation
    "$TPM_DIR/bin/install_plugins" || echo "⚠️  Some plugins may have failed to install"

    # Kill the temporary session
    tmux kill-session -t dotbot-install 2>/dev/null || true

    echo "✅ Plugins installed successfully"
    echo "💡 Plugins will load when you start tmux"
fi

# Check plugin installation
echo ""
echo "📋 Checking installed plugins:"
if [ -d "$TMUX_PLUGIN_DIR/tmux-resurrect" ]; then
    echo "  ✅ tmux-resurrect - Session persistence"
else
    echo "  ❌ tmux-resurrect - Not installed yet"
fi

if [ -d "$TMUX_PLUGIN_DIR/tmux-continuum" ]; then
    echo "  ✅ tmux-continuum - Automatic session saving"
else
    echo "  ❌ tmux-continuum - Not installed yet"
fi

if [ -d "$TMUX_PLUGIN_DIR/vim-tmux-navigator" ]; then
    echo "  ✅ vim-tmux-navigator - Vim/Tmux navigation"
else
    echo "  ❌ vim-tmux-navigator - Not installed yet"
fi

if [ -d "$TMUX_PLUGIN_DIR/minimal-tmux-status" ]; then
    echo "  ✅ minimal-tmux-status - Minimal status bar"
else
    echo "  ❌ minimal-tmux-status - Not installed yet"
fi

echo ""
echo "📁 Session save location: $RESURRECT_DIR"
echo ""
echo "🎯 Key bindings for session management:"
echo "  - Ctrl+s Ctrl+s : Save current session manually"
echo "  - Ctrl+s Ctrl+r : Restore last saved session manually"
echo "  - Auto-save runs every 15 minutes"
echo "  - Auto-restore on tmux start (configured)"
echo ""
echo "✅ Tmux plugin setup completed!"
