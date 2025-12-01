#!/usr/bin/env zsh
# ============================================================================
# ZSH Configuration
# ============================================================================

# ============================================================================
# Environment Variables
# ============================================================================

export DOTFILES_DIR="${HOME}/.dotfiles"
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
export PATH=~/.local/bin:$HOME/.opencode/bin:$PATH
export EDITOR=nvim
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
export HOMEBREW_CASK_OPTS="--no-quarantine"

# FZF Moonfly theme
export FZF_DEFAULT_OPTS="
  --color=fg:#bdbdbd,bg:#080808,hl:#80a0ff
  --color=fg+:#eeeeee,bg+:#1c1c1c,hl+:#80a0ff
  --color=info:#de935f,prompt:#80a0ff,pointer:#ff5189
  --color=marker:#8cc85f,spinner:#80a0ff,header:#8cc85f
  --color=gutter:#080808,border:#1c1c1c"

# ============================================================================
# Initialization
# ============================================================================

# Add homebrew completions to fpath
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

# Add docker completions to fpath
fpath=($HOME/.docker/completions $fpath)

# Optimized completion initialization
autoload -Uz compinit
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

# Initialize direnv
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ============================================================================
# Aliases
# ============================================================================

# Navigation & Files
alias ls="eza -la --icons=auto --git"
alias l="eza -l --icons --git -a"
alias cat="bat --style=plain --paging=never"

# Editor
alias ze="nvim ~/.dotfiles/zshrc"

# SSH with kitty terminfo (only in kitty terminal)
if [[ -n "$KITTY_WINDOW_ID" ]]; then
  alias ssh="kitten ssh"
fi

# Python
alias pvd="deactivate"

# ============================================================================
# Completions
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

# Python virtual environment activation
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

# ============================================================================
# Download Functions
# ============================================================================

# YouTube downloader with optimizations
ydl() {
  local output_format="%(title)s.%(ext)s"
  local check_cert=true

  while [[ "$1" == -* ]]; do
    case "$1" in
      -m|--movie)
        output_format="${PWD##*/}.%(ext)s"
        shift ;;
      --no-check)
        check_cert=false
        shift ;;
      *) break ;;
    esac
  done

  local cert_flag=""
  [[ "$check_cert" == false ]] && cert_flag="--no-check-certificate"

  noglob yt-dlp $cert_flag \
    -o "$output_format" \
    -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' \
    --merge-output-format mp4 \
    --concurrent-fragments 16 \
    --downloader aria2c \
    --downloader-args 'aria2c:--min-split-size=1M --max-connection-per-server=16 --max-concurrent-downloads=16 --split=16' \
    "$@"
}

# Download with custom referer
dl_with_referer() {
  local url="$1"
  local referer="${2:-https://lms.skvot.io/}"

  if [[ -z "$url" ]]; then
    echo "Usage: dl_with_referer <url> [referer]"
    return 1
  fi

  yt-dlp "$url" --referer "$referer"
}

skvotdl() {
  dl_with_referer "$1" "https://lms.skvot.io/"
}

# Video/Audio cutter
vidcut() {
  local url="" start_time="" duration=""
  local output_name="output"
  local format="mp4"

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -u|--url) url="$2"; shift ;;
      -s|--start) start_time="$2"; shift ;;
      -d|--duration) duration="$2"; shift ;;
      -o|--output) output_name="$2"; shift ;;
      -f|--format) format="$2"; shift ;;
      -h|--help)
        cat <<EOF
Usage: vidcut -u <URL> -s <START_TIME> -d <DURATION> [OPTIONS]
Options:
  -o, --output    Output filename (default: output)
  -f, --format    Output format: mp3, mp4 (default: mp4)
  -h, --help      Show this help message
EOF
        return 0 ;;
      *) echo "Unknown parameter: $1 (use -h for help)"; return 1 ;;
    esac
    shift
  done

  if [[ -z "$url" || -z "$start_time" || -z "$duration" ]]; then
    echo "🚨 Error: Required arguments missing! Use -h for help"
    return 1
  fi

  local stream_url format_desc codec_args
  case "$format" in
    mp3)
      format_desc="🎵 audio"
      stream_url=$(yt-dlp -f 'bestaudio/best' --get-url "$url")
      codec_args="-vn -c:a libmp3lame -q:a 2"
      ;;
    mp4)
      format_desc="🎬 video"
      stream_url=$(yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --get-url "$url")
      codec_args="-c copy"
      ;;
    *)
      echo "❌ Unsupported format: $format (use mp3 or mp4)"
      return 1 ;;
  esac

  echo "Cutting ${format_desc} to ${output_name}.${format}..."
  ffmpeg -ss "$start_time" -t "$duration" -i "$stream_url" $codec_args "${output_name}.${format}" -y
  echo "✅ Done!"
}

# Create Telegram sticker from video
makesticker() {
  local input="$1"

  if [[ -z "$input" || ! -f "$input" ]]; then
    echo "Usage: makesticker <input_file>"
    return 1
  fi

  local output="${input%.*}_sticker.webm"
  ffmpeg -i "$input" -r 30 -c:v libvpx-vp9 -an \
    -vf "scale=if(gte(iw\,ih)\,512\,-1):if(gte(ih\,iw)\,512\,-1),loop=0:1" \
    -t 3 -fs 256K "$output"

  [[ $? -eq 0 ]] && echo "✅ Created: $output" || echo "❌ Failed to create sticker"
}
