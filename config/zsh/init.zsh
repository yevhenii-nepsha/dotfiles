#!/usr/bin/env zsh
# ============================================================================
# ZSH Initialization
# ============================================================================

# Add homebrew completions to fpath
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

# Add docker completions to fpath
fpath=($HOME/.docker/completions $fpath)

# Optimized completion initialization
autoload -Uz compinit
# Check if .zcompdump needs to be updated (once per day)
if [[ $(($(date +%s) - $(stat -f %m ~/.zcompdump 2>/dev/null || echo 0))) -gt 86400 ]]; then
  compinit
else
  compinit -C
fi

# Enable emacs mode
bindkey -e

# Initialize starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Initialize direnv for automatic environment loading
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

