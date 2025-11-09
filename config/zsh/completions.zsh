#!/usr/bin/env zsh
# ============================================================================
# Custom Completions
# ============================================================================

# Custom completion for uv run command
_uv_run_mod() {
  if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
    _arguments '*:filename:_files'
  else
    _uv "$@"
  fi
}
compdef _uv_run_mod uv