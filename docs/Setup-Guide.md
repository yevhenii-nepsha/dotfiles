# Setup Guide

Complete guide for installing and configuring dotfiles on local machines and servers.

## Table of Contents

- [Prerequisites](#prerequisites)
- [First-Time Setup](#first-time-setup)
- [Profile System](#profile-system)
- [Server Setup](#server-setup)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting-setup)

## Prerequisites

Before installing dotfiles, ensure you have:

1. **Homebrew** - Package manager for macOS
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Dotbot** - Dotfiles installation tool
   ```bash
   pip install dotbot
   # or
   brew install dotbot
   ```

3. **Git** - Version control (usually pre-installed on macOS)

## First-Time Setup

### Local Machine (Desktop/Laptop)

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Set profile** (optional, defaults to `local`):
   ```bash
   echo "local" > ~/.dotfiles-profile
   # or use the helper script:
   ./bin/dotfiles-profile set local
   ```

3. **Run installation:**
   ```bash
   ./install
   ```

The installation will:
- Create necessary directories
- Symlink configuration files
- Install Homebrew packages from profiles
- Set up tmux plugins
- Configure git hooks
- Run health checks

### What Gets Installed (Local Profile)

**CLI Tools** (from `base.Brewfile`):
- Shell: zsh, starship prompt
- Editor: neovim
- Terminal: tmux, ghostty
- Modern CLI: eza, bat, ripgrep, fd, fzf, zoxide
- Git tools: lazygit, gh, git-delta
- Python: uv, ruff, pipx, pyright
- Languages: rust, node, python

**GUI Applications** (from `local.Brewfile`):
- Development: Docker Desktop, Claude Code CLI
- Browsers: Brave Browser, Google Chrome
- Productivity: 1Password, Raycast
- Media: Spotify, IINA
- Communication: Telegram, Signal
- Utilities: Keka, NordVPN
- Fonts: JetBrains Mono Nerd Font

## Profile System

This dotfiles repository supports multiple profiles for different machine types.

### Available Profiles

| Profile | Use Case | Packages |
|---------|----------|----------|
| **base** | Common tools | CLI tools shared by all machines |
| **local** | Desktop/Laptop | base + GUI apps + development tools |
| **server** | Mac Mini Server | base + minimal GUI + server tools |

### Managing Profiles

**View current profile:**
```bash
./bin/dotfiles-profile show
```

**Set profile:**
```bash
# For desktop/laptop
./bin/dotfiles-profile set local

# For server
./bin/dotfiles-profile set server
```

**Compare profiles:**
```bash
# Compare local vs server
./bin/brew-diff

# Compare specific profiles
./bin/brew-diff base local
```

### Profile File Structure

```
profiles/
├── base.Brewfile      # ~40 packages - Core CLI tools
├── local.Brewfile     # ~26 packages - GUI apps + dev tools
└── server.Brewfile    # ~1 package - Server-specific (Jellyfin)
```

### Adding Packages

When installing a new package, add it to the appropriate profile:

1. **All machines** → `profiles/base.Brewfile`
2. **Work machine only** → `profiles/local.Brewfile`
3. **Server only** → `profiles/server.Brewfile`

Example:
```ruby
# In profiles/base.Brewfile
brew "neovim"          # Everyone needs neovim
cask "ghostty"         # Terminal for all machines

# In profiles/local.Brewfile
cask "docker"          # Docker Desktop for development
cask "spotify"         # Media apps for personal machine

# In profiles/server.Brewfile
cask "jellyfin"        # Media server
```

**Important:** The main `Brewfile` in root is auto-generated. Always edit profile files.

## Server Setup

### Mac Mini Server Installation

1. **Clone dotfiles:**
   ```bash
   git clone <your-repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Set server profile:**
   ```bash
   ./bin/dotfiles-profile set server
   ```

3. **Install:**
   ```bash
   ./install
   ```

### Cleanup Old Installation

If updating from an old dotfiles configuration with unnecessary packages:

```bash
# Preview what will be removed (safe, no changes)
./bin/cleanup-server-packages --dry-run

# Review the list, then run cleanup
./bin/cleanup-server-packages

# Automated removal without prompts
./bin/cleanup-server-packages --yes
```

**What gets removed on server:**
- GUI apps not needed (VSCode, Chrome, fonts)
- Azure tools (only for work machine)
- Communication apps (Telegram, Signal, Zoom)
- Media apps (Spotify, IINA)
- Old packages (e.g., `docker` → `docker-desktop`)

**What stays on server:**
- All CLI tools from `base.Brewfile`
- Essential GUI (Ghostty, Brave Browser, 1Password)
- Server tools (Jellyfin, Docker Desktop)

### Server-Specific Configuration

#### Docker Services

Docker Compose configurations are automatically symlinked on server profile:

```bash
# After installation, Docker configs are at:
~/docker-compose/media/compose.yml
~/docker-compose/README.md
```

For Docker service setup, see [Docker Services Documentation](Docker-Services.md).

#### What's Installed on Server

**CLI Tools:**
- tmux, neovim, git tools
- Modern CLI: eza, bat, ripgrep, fd, fzf, starship
- Python tools: uv, ruff, pipx, pyright
- Runtimes: rust, node, python

**Minimal GUI:**
- Ghostty (terminal)
- Brave Browser
- 1Password
- Keka (archive manager)
- NordVPN

**Server-Specific:**
- Jellyfin media server
- Docker Desktop (for services)

## Maintenance

### Updating Everything

```bash
# Update dotfiles repo
cd ~/.dotfiles
git pull

# Reinstall (updates packages and configs)
./install

# Alternative: update script (runs git pull + install)
./scripts/update-all.sh
```

### Package Management

**List installed packages:**
```bash
# List all casks (GUI apps)
brew list --cask

# List all formulas (CLI tools)
brew list --formula

# List everything
brew list
```

**Update packages:**
```bash
# Update Homebrew
brew update

# Upgrade all packages
brew upgrade

# Upgrade specific package
brew upgrade neovim
```

**Clean up old versions:**
```bash
# Remove old versions
brew cleanup

# See what would be removed
brew cleanup --dry-run
```

### Health Checks

Run the health check script to verify installation:

```bash
./scripts/health-check.sh
```

This checks:
- Homebrew installation
- Required packages
- Symlink validity
- Git configuration
- Shell setup

### Backup and Restore

**Create backup:**
```bash
./scripts/backup.sh
```

Backups are stored in `~/.dotfiles-backups/`

**Restore tmux sessions:**
- Tmux sessions are automatically saved every 15 minutes
- Sessions auto-restore on tmux start
- Manual save: `prefix + Ctrl-s`
- Manual restore: `prefix + Ctrl-r`

## Troubleshooting Setup

### Profile Issues

**Check current profile:**
```bash
./bin/dotfiles-profile show
```

**Profile not set:**
If no profile is set, installation defaults to `local`. Set it explicitly:
```bash
./bin/dotfiles-profile set local  # or server
```

### Package Installation Issues

**Reinstall all packages:**
```bash
cd ~/.dotfiles
zsh ./setup_homebrew.zsh
```

**Homebrew errors:**
```bash
# Diagnose Homebrew issues
brew doctor

# Fix permissions
sudo chown -R $(whoami) /usr/local/*
```

### Symlink Issues

**Broken symlinks:**
The install script has a cleanup step that removes broken symlinks. Run:
```bash
./install
```

**Manual symlink check:**
```bash
# Find broken symlinks
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print
```

### Reset to Clean State

**Complete reset** (careful - removes all Homebrew packages):
```bash
# Remove all packages
brew list --cask | xargs brew uninstall --cask
brew list --formula | xargs brew uninstall

# Reinstall from dotfiles
cd ~/.dotfiles
./install
```

### Git Configuration Issues

**Check git config:**
```bash
git config --list --show-origin
```

**Reset git config:**
```bash
# Remove local git config
rm ~/.gitconfig

# Reinstall dotfiles
cd ~/.dotfiles
./install
```

### Shell Configuration Issues

**Zsh not default shell:**
```bash
# Set zsh as default
chsh -s $(which zsh)

# Restart terminal
```

**Shell config not loading:**
```bash
# Source manually
source ~/.zshrc

# Check for errors
zsh -x ~/.zshrc
```

## Advanced Topics

### Custom Configuration

Add your custom configurations in:
- `~/.zshrc.local` - Local zsh config (gitignored)
- `~/.gitconfig.local` - Local git config (gitignored)

### Multiple Machines

To use these dotfiles on multiple machines:

1. Fork or clone to all machines
2. Set appropriate profile on each machine
3. Use `git` to sync changes between machines
4. Machine-specific configs go in `.local` files

### Selective Installation

To install only specific components:

```bash
# Only create directories
dotbot -c install.conf.yaml --only create

# Only create symlinks
dotbot -c install.conf.yaml --only link

# Only run shell commands
dotbot -c install.conf.yaml --only shell
```

## Next Steps

- **Configure Neovim**: See [Neovim Documentation](Neovim.md)
- **Set up Tmux**: See [Tmux Documentation](Tmux.md)
- **Configure Docker Services**: See [Docker Services](Docker-Services.md)
- **Learn Git Workflow**: See [Git Workflow](Git-Workflow.md)
- **Explore Scripts**: See [Scripts Reference](Scripts-Reference.md)

## See Also

- [Troubleshooting Guide](Troubleshooting.md) - Common issues and solutions
- [Home](Home.md) - Documentation index
- [CHANGELOG](../CHANGELOG.md) - Version history
