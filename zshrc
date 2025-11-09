#!/usr/bin/env zsh
# ============================================================================
# ZSH Configuration - Modular Setup
# ============================================================================

# Define dotfiles directory
export DOTFILES_DIR="${HOME}/.dotfiles"

# Source all zsh modules
source "${DOTFILES_DIR}/config/zsh/exports.zsh"
source "${DOTFILES_DIR}/config/zsh/init.zsh"
source "${DOTFILES_DIR}/config/zsh/aliases.zsh"
source "${DOTFILES_DIR}/config/zsh/functions.zsh"
source "${DOTFILES_DIR}/config/zsh/downloads.zsh"
source "${DOTFILES_DIR}/config/zsh/completions.zsh"

# ============================================================================
# End of configuration
# ============================================================================
# opencode
export PATH=$HOME/.opencode/bin:$PATH
