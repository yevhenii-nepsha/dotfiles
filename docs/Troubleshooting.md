# Troubleshooting Guide

Comprehensive troubleshooting guide for resolving common issues with dotfiles, applications, and system configuration.

## Table of Contents

- [Installation Issues](#installation-issues)
  - [Profile Problems](#profile-problems)
  - [Package Installation](#package-installation)
  - [Symlink Issues](#symlink-issues)
- [Application Issues](#application-issues)
  - [Neovim](#neovim)
  - [Tmux](#tmux)
  - [Docker Services](#docker-services)
- [System Issues](#system-issues)
  - [Homebrew](#homebrew)
  - [Git Configuration](#git-configuration)
  - [Shell Configuration](#shell-configuration)
- [Common Patterns](#common-patterns)
  - [Diagnostic Commands](#diagnostic-commands)
  - [Reset Procedures](#reset-procedures)

---

## Installation Issues

### Profile Problems

**Symptom**: Unsure which profile is active or wrong packages installed

**Diagnosis:**
```bash
./bin/dotfiles-profile show
```

**Solution:**

Set profile explicitly:
```bash
# For desktop/laptop
./bin/dotfiles-profile set local

# For server
./bin/dotfiles-profile set server
```

**Prevention**: Always set profile before running `./install` on new machines

---

**Symptom**: Profile not set, defaults to wrong profile

**Diagnosis:**
```bash
cat ~/.dotfiles-profile
# If empty or doesn't exist, defaults to "local"
```

**Solution:**
```bash
echo "server" > ~/.dotfiles-profile  # or "local"
./install
```

---

### Package Installation

**Symptom**: Packages fail to install during setup

**Diagnosis:**
```bash
# Check Homebrew status
brew doctor

# List installed packages
brew list --cask
brew list --formula
```

**Solution:**

1. Fix Homebrew issues first:
   ```bash
   brew doctor
   brew update
   ```

2. Reinstall all packages:
   ```bash
   cd ~/.dotfiles
   zsh ./setup_homebrew.zsh
   ```

3. If specific package fails:
   ```bash
   # Uninstall problematic package
   brew uninstall package-name

   # Clean Homebrew cache
   brew cleanup

   # Reinstall
   brew install package-name
   ```

**Prevention**: Run `brew update` regularly to avoid stale package definitions

---

**Symptom**: Cask installation fails with permission errors

**Diagnosis:**
```bash
brew install --cask app-name
# Check error message for permission issues
```

**Solution:**
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/*

# For Apple Silicon Macs:
sudo chown -R $(whoami) /opt/homebrew/*
```

---

### Symlink Issues

**Symptom**: Configuration files not loading or broken symlinks

**Diagnosis:**
```bash
# Find broken symlinks in home directory
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print
```

**Solution:**

1. Run install script (includes cleanup):
   ```bash
   cd ~/.dotfiles
   ./install
   ```

2. Manual symlink fix:
   ```bash
   # Remove broken symlink
   rm ~/.broken-link

   # Recreate with dotbot
   dotbot -c ~/.dotfiles/install.conf.yaml
   ```

**Prevention**: Use `./install` script instead of manually creating symlinks

---

## Application Issues

### Neovim

#### Plugin Not Loading

**Symptom**: Plugin installed but not working

**Diagnosis:**
```vim
:Lazy
" Check for errors in plugin list

:checkhealth lazy
```

**Solution:**

1. Check lazy loading configuration:
   ```lua
   -- In plugin file, ensure event is correct
   event = { "BufReadPre", "BufNewFile" }
   ```

2. Force reload:
   ```vim
   :Lazy reload plugin-name
   ```

3. Reinstall plugin:
   ```vim
   :Lazy clean
   :Lazy install
   ```

**Prevention**: Always use appropriate lazy loading events for plugins

---

#### LSP Not Working

**Symptom**: No autocomplete, go-to-definition, or diagnostics

**Diagnosis:**
```vim
:LspInfo          " Check if LSP attached
:Mason            " Check if server installed
:checkhealth lsp  " Diagnose LSP issues
```

**Solution:**

1. Check if language server is installed:
   ```vim
   :Mason
   " Install missing server
   ```

2. Verify server in configuration:
   ```lua
   -- In lua/plugins/lsp.lua
   local servers = {
       pyright = {},  -- Ensure your server is listed
   }
   ```

3. Restart LSP:
   ```vim
   :LspRestart
   ```

4. Check logs:
   ```vim
   :LspLog
   ```

**Prevention**: Always add new language servers to `lsp.lua` configuration

---

#### Formatting Not Working

**Symptom**: Auto-format on save doesn't work

**Diagnosis:**
```vim
:Mason               " Check if formatters installed
:checkhealth null-ls
```

**Solution:**

1. Check formatter installation:
   ```vim
   :Mason
   " Look for formatter (prettier, stylua, ruff, etc)
   ```

2. Verify formatter in configuration:
   ```lua
   -- In lua/plugins/autoformatting.lua
   ensure_installed = {
       "prettier",
       "your-formatter",  -- Ensure it's listed
   }
   ```

3. Manually format:
   ```vim
   :lua vim.lsp.buf.format()
   ```

**Prevention**: Check `:Mason` after adding new formatters to ensure they're installed

---

#### Slow Startup

**Symptom**: Neovim takes long time to start

**Diagnosis:**
```vim
:Lazy profile
" Shows plugin startup times
```

**Solution:**

1. Review plugin loading:
   ```vim
   :Lazy profile
   " Look for plugins with high load times
   ```

2. Add lazy loading to slow plugins:
   ```lua
   -- Change from:
   lazy = false

   -- To:
   event = { "BufReadPre", "BufNewFile" }
   ```

3. Check plugin count:
   ```vim
   :Lazy
   " Should show ~30-40 active plugins
   ```

**Prevention**: Always use lazy loading for non-essential plugins

---

#### Restore Default Config

**Symptom**: Configuration broken after changes

**Solution:**
```bash
cd ~/.dotfiles/config/nvim
git restore .
nvim  # Restart neovim
```

---

### Tmux

#### Sessions Not Restoring

**Symptom**: Tmux doesn't restore previous session on startup

**Diagnosis:**
```bash
# Check if auto-restore is enabled
tmux show-options -g | grep continuum-restore
# Should show: @continuum-restore on

# Check if saved sessions exist
ls -lah ~/.config/tmux/resurrect/
```

**Solution:**

1. Enable auto-restore:
   ```bash
   # In ~/.config/tmux/tmux.conf, ensure:
   set -g @continuum-restore 'on'

   # Reload config
   tmux source-file ~/.config/tmux/tmux.conf
   ```

2. Manually restore session:
   ```
   Ctrl+s Ctrl+r
   # Or run:
   ~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh
   ```

3. Check save directory permissions:
   ```bash
   ls -la ~/.config/tmux/resurrect/
   chmod 755 ~/.config/tmux/resurrect/
   ```

**Prevention**: Verify auto-restore is enabled after config changes

---

#### Auto-save Not Working

**Symptom**: Sessions not automatically saving every 15 minutes

**Diagnosis:**
```bash
# Check save interval
tmux show-options -g | grep continuum-save-interval
# Should show: @continuum-save-interval 15

# Check last save timestamp
tmux show-options -g | grep continuum-save-last-timestamp
```

**Solution:**

1. Verify continuum plugin is loaded:
   ```bash
   tmux show-options -g | grep continuum
   ```

2. Manually trigger save to test:
   ```
   Ctrl+s Ctrl+s
   # Or run:
   ~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh
   ```

3. Reinstall tmux plugins:
   ```bash
   ~/.dotfiles/scripts/setup-tmux-plugins.sh
   ```

**Prevention**: Check timestamps periodically to ensure auto-save is working

---

#### Pane Contents Not Saving

**Symptom**: Restored sessions don't have previous pane contents

**Diagnosis:**
```bash
tmux show-options -g | grep resurrect-capture-pane-contents
# Should show: @resurrect-capture-pane-contents on
```

**Solution:**
```bash
# In ~/.config/tmux/tmux.conf, ensure:
set -g @resurrect-capture-pane-contents 'on'

# Reload config
tmux source-file ~/.config/tmux/tmux.conf
```

---

#### Nested Tmux Prefix Issues

**Symptom**: After reloading config, Ctrl+S doesn't work (only Ctrl+A works)

**Diagnosis:**
```bash
# Check if inside tmux
echo $TMUX

# Check nested status
echo $TMUX_NESTED
```

**Solution:**

**Option 1: Restart tmux (recommended)**
```bash
exit  # or Ctrl+A d (if you reloaded and have Ctrl+A)
tmux  # Start again - Ctrl+S should work correctly
```

**Option 2: Quick fix without restarting**
```bash
tmux set -g prefix C-s
tmux bind C-s send-prefix
tmux set -g status-style "bg=colour235,fg=colour250"
```

**Prevention**: Restart tmux after config changes instead of reloading

---

#### Plugin Installation Fails

**Symptom**: TPM plugins not installing or updating

**Diagnosis:**
```bash
# Check if TPM is installed
ls ~/.config/tmux/plugins/tpm

# Check plugin directory
ls -la ~/.config/tmux/plugins/
```

**Solution:**

1. Run setup script:
   ```bash
   ~/.dotfiles/scripts/setup-tmux-plugins.sh
   ```

2. Manual installation:
   ```bash
   # Install TPM
   git clone https://github.com/tmux-plugins/tpm \
     ~/.config/tmux/plugins/tpm

   # Install plugins
   ~/.config/tmux/plugins/tpm/bin/install_plugins
   ```

3. In tmux:
   ```
   Ctrl+s I  # Install plugins
   Ctrl+s U  # Update plugins
   ```

**Prevention**: Run setup script after cloning dotfiles on new machines

---

### Docker Services

#### Tunnel Connection Errors

**Symptom**: Cloudflare tunnel not connecting

**Diagnosis:**
```bash
# Check tunnel logs
cd ~/docker-compose/media
docker compose logs tunnel

# Verify token is set
docker compose config | grep TUNNEL_TOKEN
```

**Solution:**

1. Check `.env` file:
   ```bash
   cd ~/docker-compose/media
   cat .env
   # Verify TUNNEL_TOKEN is set
   ```

2. Get new token from Cloudflare:
   - Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
   - Navigate to: Access > Tunnels > [Your Tunnel]
   - Copy token from install command

3. Update `.env` and restart:
   ```bash
   # Edit .env with new token
   vim .env

   # Restart tunnel
   docker compose restart tunnel
   ```

**Prevention**: Store tunnel token securely and verify it's correct during setup

---

#### Navidrome Not Accessible

**Symptom**: Can't access Navidrome web interface

**Diagnosis:**
```bash
# Check if container is running
docker ps | grep navidrome

# Check logs
cd ~/docker-compose/media
docker compose logs navidrome

# Verify port is listening
lsof -i :4533
```

**Solution:**

1. Restart Navidrome:
   ```bash
   cd ~/docker-compose/media
   docker compose restart navidrome
   ```

2. Check volume permissions:
   ```bash
   # Verify directories exist and are accessible
   ls -la ~/.config/navidrome
   ls -la /path/to/music/library
   ```

3. Recreate container:
   ```bash
   docker compose down
   docker compose up -d --force-recreate
   ```

**Prevention**: Verify volume paths in `compose.yml` match actual directories

---

#### Music Library Not Visible

**Symptom**: Navidrome starts but shows no music

**Diagnosis:**
```bash
# Check if music directory exists
ls -la /Volumes/archive/music/Library

# Check permissions
id  # Note your UID
```

**Solution:**

1. Verify volume mount in `compose.yml`:
   ```yaml
   volumes:
     - "/correct/path/to/music:/music:rw"
   ```

2. Check directory permissions:
   ```bash
   # Ensure directory is readable
   chmod -R 755 /path/to/music
   ```

3. Update user ID in compose.yml if needed:
   ```yaml
   user: "1000:1000"  # Match your UID from `id` command
   ```

4. Trigger rescan:
   ```bash
   docker compose restart navidrome
   ```

**Prevention**: Document music library path and verify it's mounted before starting services

---

## System Issues

### Homebrew

#### brew doctor Errors

**Symptom**: `brew doctor` shows warnings or errors

**Diagnosis:**
```bash
brew doctor
```

**Solution:**

Common fixes:
```bash
# Fix permissions
sudo chown -R $(whoami) /usr/local/*
# For Apple Silicon:
sudo chown -R $(whoami) /opt/homebrew/*

# Update Homebrew
brew update

# Clean up old versions
brew cleanup

# Fix broken symlinks
brew link --overwrite --force package-name
```

**Prevention**: Run `brew doctor` periodically and address warnings

---

#### Package Installation Fails

**Symptom**: Cannot install specific package

**Diagnosis:**
```bash
brew install package-name
# Read error message carefully
```

**Solution:**

1. Update Homebrew:
   ```bash
   brew update
   ```

2. Clear cache and retry:
   ```bash
   brew cleanup -s
   rm -rf $(brew --cache)
   brew install package-name
   ```

3. Install from alternate source:
   ```bash
   # Try installing from source
   brew install --build-from-source package-name
   ```

**Prevention**: Keep Homebrew updated with `brew update` regularly

---

### Git Configuration

#### Git Config Not Loading

**Symptom**: Git settings (name, email, aliases) not working

**Diagnosis:**
```bash
git config --list --show-origin
```

**Solution:**

1. Check symlink:
   ```bash
   ls -la ~/.gitconfig
   # Should point to ~/.dotfiles/config/git/gitconfig
   ```

2. Recreate symlink:
   ```bash
   cd ~/.dotfiles
   ./install
   ```

3. Manual fix:
   ```bash
   ln -sf ~/.dotfiles/config/git/gitconfig ~/.gitconfig
   ```

**Prevention**: Use `./install` script to manage symlinks

---

#### Git Config Overrides

**Symptom**: Custom settings being overridden

**Diagnosis:**
```bash
git config --list --show-origin
# Check which config file sets each value
```

**Solution:**

Add machine-specific settings to `.gitconfig.local`:
```bash
# Create local config (gitignored)
vim ~/.gitconfig.local

# Add your overrides:
[user]
    email = custom@email.com
```

**Prevention**: Use `.local` files for machine-specific configs

---

### Shell Configuration

#### Zsh Not Default Shell

**Symptom**: Terminal opens with bash instead of zsh

**Diagnosis:**
```bash
echo $SHELL
# Should show: /bin/zsh or /usr/local/bin/zsh
```

**Solution:**
```bash
# Set zsh as default
chsh -s $(which zsh)

# Restart terminal
```

**Prevention**: Verify default shell after OS updates

---

#### Shell Config Not Loading

**Symptom**: Aliases, functions, or prompt not working

**Diagnosis:**
```bash
# Check if .zshrc exists and is symlinked
ls -la ~/.zshrc

# Test config for errors
zsh -x ~/.zshrc
```

**Solution:**

1. Source manually:
   ```bash
   source ~/.zshrc
   ```

2. Fix symlink:
   ```bash
   cd ~/.dotfiles
   ./install
   ```

3. Check for syntax errors:
   ```bash
   zsh -n ~/.zshrc
   # If errors, fix in ~/.dotfiles/config/zsh/
   ```

**Prevention**: Test shell config changes in new terminal window before closing current one

---

#### Slow Shell Startup

**Symptom**: New terminal takes long time to open

**Diagnosis:**
```bash
# Profile zsh startup
time zsh -i -c exit
```

**Solution:**

1. Check for slow plugins:
   ```bash
   # Add to top of ~/.zshrc temporarily:
   zmodload zsh/zprof

   # Add to bottom:
   zprof
   ```

2. Disable or optimize slow components

**Prevention**: Use lazy loading for non-essential shell features

---

## Common Patterns

### Diagnostic Commands

Quick commands for diagnosing common issues:

**System:**
```bash
# OS and arch info
uname -a

# Homebrew status
brew doctor
brew config

# Shell info
echo $SHELL
zsh --version
```

**Dotfiles:**
```bash
# Current profile
./bin/dotfiles-profile show

# Compare profiles
./bin/brew-diff

# Health check
./scripts/health-check.sh
```

**Neovim:**
```vim
:checkhealth            " Overall health check
:LspInfo                " LSP status
:Mason                  " Tool manager
:Lazy                   " Plugin manager
:Telescope keymaps      " Search keybindings
```

**Tmux:**
```bash
# Session info
tmux info

# Plugin status
tmux show-options -g | grep -E '(resurrect|continuum)'

# List sessions
tmux ls
```

**Docker:**
```bash
# Container status
docker ps -a

# Service logs
docker compose logs -f

# Resource usage
docker stats
```

---

### Reset Procedures

#### Reset Neovim Config

```bash
# Backup current config
mv ~/.config/nvim ~/.config/nvim.backup

# Restore from dotfiles
cd ~/.dotfiles
./install

# Or git restore
cd ~/.dotfiles/config/nvim
git restore .
```

---

#### Reset Tmux Config

```bash
# Kill all tmux sessions
tmux kill-server

# Remove saved sessions
rm -rf ~/.config/tmux/resurrect/*

# Reinstall plugins
~/.dotfiles/scripts/setup-tmux-plugins.sh

# Start fresh
tmux
```

---

#### Reset Homebrew Packages

**Warning**: This removes all installed packages

```bash
# Remove all casks (GUI apps)
brew list --cask | xargs brew uninstall --cask

# Remove all formulas (CLI tools)
brew list --formula | xargs brew uninstall

# Reinstall from dotfiles
cd ~/.dotfiles
./install
```

---

#### Reset Docker Services

```bash
cd ~/docker-compose/media

# Stop and remove containers
docker compose down

# Remove volumes (WARNING: deletes data)
docker compose down -v

# Remove images
docker compose down --rmi all

# Start fresh
docker compose up -d
```

---

#### Complete Dotfiles Reset

```bash
# Remove all symlinks
cd ~/.dotfiles
dotbot -c install.conf.yaml --only unlink

# Pull latest changes
git pull

# Reinstall everything
./install
```

---

## Quick Troubleshooting Checklist

When something isn't working, try these steps in order:

1. **Check logs/status**
   - Read error messages carefully
   - Check relevant log files
   - Use diagnostic commands above

2. **Verify configuration**
   - Check if config files are symlinked correctly
   - Verify settings match documentation
   - Look for typos or syntax errors

3. **Restart the service**
   - Reload config files
   - Restart the application
   - Restart terminal/shell

4. **Reinstall/reset**
   - Reinstall plugins/packages
   - Reset configuration to defaults
   - Use reset procedures above

5. **Check for updates**
   - Update Homebrew packages
   - Update plugins (nvim, tmux)
   - Pull latest dotfiles changes

6. **Ask for help**
   - Include error messages
   - Share relevant config snippets
   - Describe steps to reproduce

---

**Last Updated**: 2025-11-06
