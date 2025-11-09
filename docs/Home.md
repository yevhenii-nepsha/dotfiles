# Dotfiles Documentation

Welcome to the comprehensive documentation for this dotfiles repository. This documentation covers installation, configuration, and usage of all tools and scripts.

## Quick Navigation

### Getting Started
- **[Setup Guide](Setup-Guide.md)** - Installation and initial configuration
  - First-time setup
  - Profile system (base/local/server)
  - Server-specific setup
  - Maintenance and updates

### Applications & Tools
- **[Neovim](Neovim.md)** - Complete Neovim configuration reference
  - Keybindings and plugins
  - LSP and autocompletion
  - Adding new plugins
  - Troubleshooting

- **[Tmux](Tmux.md)** - Terminal multiplexer guide
  - Quick start guide
  - Session management
  - Nested tmux configuration
  - Persistence and restoration

- **[Docker Services](Docker-Services.md)** - Server services management
  - Media stack (Navidrome + Cloudflare Tunnel)
  - Setup and configuration
  - Service management

### Development
- **[Git Workflow](Git-Workflow.md)** - Git commit standards and workflows
  - Commit message format
  - Git hooks
  - Creating pull requests

- **[Scripts Reference](Scripts-Reference.md)** - Utility scripts and commands
  - Maintenance scripts
  - Profile management
  - Health checks and backups

### Reference
- **[Troubleshooting](Troubleshooting.md)** - Common issues and solutions
  - Neovim issues
  - Tmux issues
  - Docker issues
  - Homebrew issues

## Quick Links

### Common Tasks
- [Installing dotfiles for the first time](Setup-Guide.md#first-time-setup)
- [Setting up server profile](Setup-Guide.md#server-setup)
- [Adding a new Neovim plugin](Neovim.md#adding-plugins)
- [Managing tmux sessions](Tmux.md#session-management)
- [Starting Docker services](Docker-Services.md#setup)
- [Updating everything](Setup-Guide.md#maintenance)

### Essential Commands
```bash
# Install/update dotfiles
./install

# Update all packages and dotfiles
./scripts/update-all.sh

# Run health check
./scripts/health-check.sh

# Set profile (base/local/server)
./bin/dotfiles-profile set <profile>

# Compare installed vs expected packages
./bin/brew-diff
```

## Repository Structure

```
.dotfiles/
├── config/          # Application configurations
│   ├── nvim/       # Neovim configuration
│   ├── tmux/       # Tmux configuration
│   ├── ghostty/    # Ghostty terminal config
│   └── ...
├── profiles/        # Brewfile profiles
│   ├── base.Brewfile    # Core tools (all machines)
│   ├── local.Brewfile   # Desktop apps
│   └── server.Brewfile  # Server-specific
├── docker-compose/  # Docker service configs
├── scripts/         # Maintenance scripts
├── bin/             # User executables
├── docs/            # Documentation (you are here)
└── CLAUDE.md        # Claude Code instructions
```

## Documentation Guidelines

- All user-facing documentation is in `docs/`
- Application-specific configs may have README symlinks
- Use markdown format for all documentation
- Include examples and code blocks
- Add troubleshooting sections where applicable

## Version Information

Current dotfiles version: **2.0.0**

For version history and changelog, see [CHANGELOG.md](../CHANGELOG.md)

## Getting Help

1. Check the relevant documentation page
2. Look in [Troubleshooting](Troubleshooting.md)
3. Search for error messages in docs
4. Check application-specific README files

## Contributing

This is a personal dotfiles repository. If you're forking it:
1. Review [Setup Guide](Setup-Guide.md) for installation
2. Customize `CLAUDE.md` for your preferences
3. Modify Brewfile profiles for your tools
4. Update documentation as you make changes
