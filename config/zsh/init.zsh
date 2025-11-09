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

# Detect nested tmux via SSH connection
# If connecting via SSH, assume we're in nested tmux (local tmux -> SSH -> remote tmux)
if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
  export TMUX_NESTED=1
fi

# Auto-attach to tmux session or restore last saved session
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  # Check if there are running sessions
  if tmux list-sessions &>/dev/null; then
    # Attach to main or first available session
    tmux attach-session -t main 2>/dev/null || tmux attach-session
  else
    # No running sessions - check if there's a saved session to restore
    if [ -f ~/.config/tmux/resurrect/last ]; then
      # Start tmux (continuum will auto-restore the last saved session)
      tmux
    else
      # No saved sessions - create new 'main' session
      tmux new-session -s main
    fi
  fi
fi