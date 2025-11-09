#!/usr/bin/env zsh
# ============================================================================
# Environment Variables
# ============================================================================

export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
export PATH=~/.local/bin:$PATH
export EDITOR=nvim
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
export HOMEBREW_CASK_OPTS="--no-quarantine"

# FZF Moonfly theme
# https://github.com/bluz71/vim-moonfly-colors/blob/master/extras/moonfly-fzf.sh
export FZF_DEFAULT_OPTS="
  --color=fg:#bdbdbd,bg:#080808,hl:#80a0ff
  --color=fg+:#eeeeee,bg+:#1c1c1c,hl+:#80a0ff
  --color=info:#de935f,prompt:#80a0ff,pointer:#ff5189
  --color=marker:#8cc85f,spinner:#80a0ff,header:#8cc85f
  --color=gutter:#080808,border:#1c1c1c"