#!/usr/bin/env zsh
# ============================================================================
# Utility Functions
# ============================================================================

# Smart nvim launcher
unalias v 2>/dev/null || true
v() {
  if [[ $# -eq 0 ]]; then
    nvim .
  else
    nvim "$@"
  fi
}

# Python virtual environment activation (checks multiple common locations)
pva() {
  local venv_paths=("venv" ".venv" "env" ".env")

  for venv_path in "${venv_paths[@]}"; do
    if [[ -f "${venv_path}/bin/activate" ]]; then
      source "${venv_path}/bin/activate"
      echo "✅ Activated: ${venv_path}"
      return 0
    fi
  done

  echo "🚫 No virtual environment found"
  echo "💡 Checked: ${venv_paths[*]}"
  return 1
}

# Create and change directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Unlock directory with confirmation
unlockdir() {
  local target_dir="${1:-.}"

  if [[ ! -d "$target_dir" ]]; then
    echo "❌ Directory not found: $target_dir"
    return 1
  fi

  local real_path=$(realpath "$target_dir")
  echo "⚠️  About to unlock: $real_path"
  echo -n "Continue? [y/N] "
  read -r response

  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "🔓 Unlocking..."
    chflags -R nouchg "$target_dir" && chmod -R u+w "$target_dir"
    echo "✅ Done!"
  else
    echo "❌ Cancelled"
  fi
}

# Smart tmux launcher with nested detection
# Automatically sets TMUX_NESTED=1 when starting tmux inside tmux
tmux() {
  if [[ -n "$TMUX" ]]; then
    # Already inside tmux, set TMUX_NESTED for nested session
    TMUX_NESTED=1 command tmux "$@"
  else
    # Not inside tmux, run normally
    command tmux "$@"
  fi
}
