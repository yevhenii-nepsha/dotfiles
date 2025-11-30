# ============================================================================
# Base Brewfile - Common packages for all machines
# ============================================================================
# This profile includes essential CLI tools, development tools, and Docker
# that are needed on both local development machine and Mac Mini server.

# ============================================================================
# TAPS - Third-party repositories
# ============================================================================
tap "FelixKratz/formulae"            # Custom macOS tools (sketchybar, etc)

# ============================================================================
# PROGRAMMING LANGUAGES & RUNTIMES
# ============================================================================
brew "rust"                          # Rust programming language
brew "node"                          # JavaScript runtime
brew "python@3.13"                   # Python 3.13

# ============================================================================
# CORE DEVELOPMENT TOOLS
# ============================================================================
brew "neovim"                        # Modern Vim-based editor
brew "lua-language-server"           # LSP for Lua (neovim configuration)
brew "tree-sitter"                   # Parser generator for syntax highlighting
brew "tmux"                          # Terminal multiplexer
brew "lazygit"                       # Simple terminal UI for git commands
brew "gh"                            # GitHub CLI tool
brew "bfg"                           # Remove large files from git history
brew "direnv"                        # Load/unload environment variables

# ============================================================================
# PYTHON DEVELOPMENT
# ============================================================================
brew "uv"                            # Fast Python package installer and resolver
brew "ruff"                          # Fast Python linter and formatter
brew "pipx"                          # Install Python apps in isolated environments
brew "pyright"                       # Python static type checker
brew "isort"                         # Python import sorter

# ============================================================================
# MODERN CLI TOOLS (Rust-based replacements)
# ============================================================================
brew "eza"                           # Modern replacement for ls
brew "bat"                           # Modern replacement for cat
brew "bat-extras"                    # Additional bat-based tools
brew "ripgrep"                       # Fast grep replacement (rg)
brew "fd"                            # Fast find replacement
brew "fzf"                           # Fuzzy finder (ESSENTIAL)
brew "starship"                      # Cross-shell prompt

# ============================================================================
# FILE MANAGEMENT & NAVIGATION
# ============================================================================
brew "yazi"                          # Terminal file manager
brew "tree"                          # Directory tree viewer

# ============================================================================
# TEXT & DATA PROCESSING
# ============================================================================
brew "jq"                            # JSON processor (ESSENTIAL)

# ============================================================================
# KNOWLEDGE MANAGEMENT & NOTE-TAKING
# ============================================================================
brew "zk"                            # Plain text note-taking assistant

# ============================================================================
# SYSTEM MONITORING & INFO
# ============================================================================
brew "htop"                          # Interactive process viewer
brew "neofetch"                      # System information display
brew "tldr"                          # Simplified man pages

# ============================================================================
# DOWNLOAD & MEDIA TOOLS
# ============================================================================
brew "yt-dlp"                        # YouTube and media downloader
brew "aria2"                         # Multi-protocol download utility
brew "ffmpeg"                        # Video/audio converter and processor

# ============================================================================
# NETWORK & API TOOLS
# ============================================================================
brew "xh"                            # Fast HTTP client (httpie alternative)

# ============================================================================
# SECURITY
# ============================================================================
brew "gnupg"                         # GNU Privacy Guard (GPG)

# ============================================================================
# CONTAINERS
# ============================================================================
cask "docker"                        # Docker Desktop (container engine + GUI)

# ============================================================================
# APPLICATIONS - DEVELOPMENT TOOLS
# ============================================================================
cask "claude-code"                   # Claude Code CLI tool

# ============================================================================
# APPLICATIONS - ESSENTIAL GUI (both machines)
# ============================================================================
cask "ghostty"                       # Fast terminal emulator
cask "zen"                           # Privacy-focused browser
cask "1password"                     # Password manager
cask "keka"                          # Archive manager
cask "nordvpn"                       # VPN client
