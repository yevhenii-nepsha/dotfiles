# Dotfiles

Personal dotfiles for macOS with support for multiple machine profiles.

## Quick Start

```bash
# Clone dotfiles
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# Set profile (optional, defaults to 'local')
echo "local" > ~/.dotfiles-profile   # For desktop/laptop
# or
echo "server" > ~/.dotfiles-profile  # For Mac Mini server

# Install (automatically installs Homebrew and all packages)
./install
```

## Documentation

**Full documentation is available in [`docs/`](docs/Home.md)**

### Quick Links

- **[Setup Guide](docs/Setup-Guide.md)** - Complete installation and configuration guide
- **[Neovim](docs/Neovim.md)** - Neovim configuration and keybindings
- **[Tmux](docs/Tmux.md)** - Tmux setup and session management
- **[Docker Services](docs/Docker-Services.md)** - Server services (Navidrome, Cloudflare Tunnel)
- **[Git Workflow](docs/Git-Workflow.md)** - Commit standards and git hooks
- **[Scripts Reference](docs/Scripts-Reference.md)** - Utility scripts documentation
- **[Troubleshooting](docs/Troubleshooting.md)** - Common issues and solutions

## Features

### Multi-Profile System

Support for different machine types:
- **base** - Core CLI tools (all machines)
- **local** - Desktop/laptop with GUI apps and development tools
- **server** - Mac Mini with minimal GUI and server-specific tools

```bash
# Manage profiles
./bin/dotfiles-profile show          # Current profile
./bin/dotfiles-profile set local     # Set profile
./bin/brew-diff                      # Compare profiles
```

### Included Tools

**CLI Tools:**
- Shell: zsh with starship prompt
- Editor: neovim with LSP, treesitter, autocompletion
- Terminal: tmux with session persistence
- Modern CLI: eza, bat, ripgrep, fd, fzf, zoxide
- Git: lazygit, gh, git-delta
- Development: Podman (Docker alternative), Claude Code CLI

**Server Services:**
- Navidrome (music streaming)
- Cloudflare Tunnel (secure proxy)
- Jellyfin (media server)

See [Setup Guide](docs/Setup-Guide.md) for complete package lists.

## Maintenance

```bash
# Update everything
./scripts/update-all.sh

# Run health check
./scripts/health-check.sh

# Create backup
./scripts/backup.sh

# Clean up packages not in Brewfile
brew bundle cleanup --force
```

## Structure

```
.dotfiles/
├── config/          # Application configurations
│   ├── nvim/       # Neovim
│   ├── tmux/       # Tmux
│   ├── kitty/      # Kitty terminal
│   └── ...
├── profiles/        # Brewfile profiles
│   ├── base.Brewfile
│   ├── local.Brewfile
│   └── server.Brewfile
├── docker-compose/  # Docker service configs
├── scripts/         # Maintenance scripts
├── bin/             # User executables
├── docs/            # Documentation
└── CLAUDE.md        # Claude Code instructions
```

## License

Personal dotfiles - feel free to fork and adapt for your own use.
