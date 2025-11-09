#!/usr/bin/env zsh
# ============================================================================
# Download Functions
# ============================================================================

# YouTube downloader with optimizations
ydl() {
  local output_format="%(title)s.%(ext)s"
  local check_cert=true

  # Parse arguments
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

# Download with custom referer (refactored skvotdl function)
dl_with_referer() {
  local url="$1"
  local referer="${2:-https://lms.skvot.io/}"

  if [[ -z "$url" ]]; then
    echo "Usage: dl_with_referer <url> [referer]"
    echo "       skvotdl() is available as alias for lms.skvot.io"
    return 1
  fi

  yt-dlp "$url" --referer "$referer"
}

# Alias for old skvotdl function
skvotdl() {
  dl_with_referer "$1" "https://lms.skvot.io/"
}

# Video/Audio cutter (refactored to reduce duplication)
vidcut() {
  local url="" start_time="" duration=""
  local output_name="output"
  local format="mp4"

  # Argument parsing
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

  # Validation
  if [[ -z "$url" || -z "$start_time" || -z "$duration" ]]; then
    echo "🚨 Error: Required arguments missing! Use -h for help"
    return 1
  fi

  # Get stream URL based on format
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