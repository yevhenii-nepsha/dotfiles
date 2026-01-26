#!/usr/bin/env zsh

# Function to add Homebrew to the PATH for the current script session
setup_brew_path() {
    # Detect architecture and set the correct Homebrew path
    local brew_path
    if [[ "$(uname -m)" == "arm64" ]]; then
        # For Apple Silicon (M1/M2/M3...)
        brew_path="/opt/homebrew/bin"
    else
        # For Intel Macs
        brew_path="/usr/local/bin"
    fi

    # Add to PATH if it's not already there
    if [[ ":$PATH:" != *":${brew_path}:"* ]]; then
        export PATH="${brew_path}:$PATH"
    fi
}

# Function to detect the current dotfiles profile
detect_profile() {
    local profile="local"  # Default to local

    # Check for profile in order of priority:
    # 1. Environment variable
    if [[ -n "$DOTFILES_PROFILE" ]]; then
        profile="$DOTFILES_PROFILE"
    # 2. Profile file
    elif [[ -f ~/.dotfiles-profile ]]; then
        profile=$(cat ~/.dotfiles-profile | tr -d '[:space:]')
    fi

    # Validate profile
    if [[ "$profile" != "local" && "$profile" != "server" ]]; then
        echo "⚠️  Invalid profile '$profile', defaulting to 'local'"
        profile="local"
    fi

    echo "$profile"
}

# Function to generate Brewfile from profiles
generate_brewfile() {
    local profile="$1"
    local dotfiles_dir="$2"
    local output_file="${dotfiles_dir}/Brewfile"

    echo "🔧 Generating Brewfile for profile: $profile"

    # Start with base profile
    if [[ -f "${dotfiles_dir}/profiles/base.Brewfile" ]]; then
        cat "${dotfiles_dir}/profiles/base.Brewfile" > "$output_file"
    else
        echo "❌ Base profile not found: ${dotfiles_dir}/profiles/base.Brewfile"
        return 1
    fi

    # Append profile-specific packages
    local profile_file="${dotfiles_dir}/profiles/${profile}.Brewfile"
    if [[ -f "$profile_file" ]]; then
        echo "" >> "$output_file"
        echo "# ============================================================================" >> "$output_file"
        echo "# Profile-specific packages (${profile})" >> "$output_file"
        echo "# ============================================================================" >> "$output_file"
        cat "$profile_file" >> "$output_file"
    else
        echo "⚠️  Profile file not found: $profile_file"
    fi

    echo "✅ Brewfile generated at: $output_file"
}

# --- Main Logic ---

# Detect dotfiles directory
DOTFILES_DIR="${0:a:h}"

# Detect the profile
PROFILE=$(detect_profile)
echo "📋 Using profile: $PROFILE"

# Check if brew command exists
if command -v brew >/dev/null 2>&1; then
    echo "✅ Brew is already installed, skipping installation."
else
    echo "\n🔵 Homebrew not found. Starting installation...\n"
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Check if installation was successful before proceeding
    if [[ $? -ne 0 ]]; then
        echo "❌ Homebrew installation failed."
        exit 1
    fi
fi

# Add Homebrew to PATH for this script's context
setup_brew_path

# Generate Brewfile based on profile
generate_brewfile "$PROFILE" "$DOTFILES_DIR"

# Check if Brewfile generation was successful
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to generate Brewfile"
    exit 1
fi

# Now that brew is in PATH, run bundle
echo "📦 Running 'brew bundle'..."
brew bundle --verbose

# Check for packages not in Brewfile
echo "\n🔍 Checking for packages not in Brewfile..."
extra_packages=$(brew bundle cleanup 2>/dev/null)

if [[ -n "$extra_packages" ]]; then
    echo "$extra_packages"
    echo ""
    read "response?Remove these packages? (y/N): "
    if [[ "$response" =~ ^[Yy]$ ]]; then
        brew bundle cleanup --force
        echo "✅ Extra packages removed"
    else
        echo "ℹ️  Skipped. Run 'brew bundle cleanup --force' later to remove."
    fi
else
    echo "✅ No extra packages found"
fi

echo "\n✨ Homebrew setup complete for profile: $PROFILE"

