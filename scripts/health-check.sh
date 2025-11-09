#!/usr/bin/env bash
# ============================================================================
# Dotfiles Health Check Script
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ISSUES=0
WARNINGS=0
CHECKS=0

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ISSUES++))
}

check_symlinks() {
    log_info "Checking symlink health..."

    local broken_links=()

    # Check common dotfiles symlinks
    local dotfiles=(
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
        "$HOME/.gitmessage"
        "$HOME/.gitignore_global"
        "$HOME/.vimrc"
        "$HOME/.psqlrc"
    )

    for file in "${dotfiles[@]}"; do
        if [[ -L "$file" ]]; then
            if [[ ! -e "$file" ]]; then
                broken_links+=("$file")
            else
                log_success "$(basename "$file") symlink is valid"
            fi
        elif [[ -e "$file" ]]; then
            log_warning "$(basename "$file") exists but is not a symlink"
        else
            log_warning "$(basename "$file") not found"
        fi
    done || true

    # Check config directory symlinks
    local config_dirs=(
        "$HOME/.config/nvim"
        "$HOME/.config/kitty"
        "$HOME/.config/ghostty"
        "$HOME/.config/yazi"
        "$HOME/.config/bat"
    )

    # Check specific config files
    local config_files=(
        "$HOME/.config/tmux/tmux.conf"
        "$HOME/.config/musikcube/hotkeys.json"
    )

    for dir in "${config_dirs[@]}"; do
        if [[ -L "$dir" ]]; then
            if [[ ! -e "$dir" ]]; then
                broken_links+=("$dir")
            else
                log_success "$(basename "$dir") config symlink is valid"
            fi
        elif [[ -d "$dir" ]]; then
            log_warning "$(basename "$dir") config exists but is not a symlink"
        else
            log_warning "$(basename "$dir") config not found"
        fi
    done || true

    # Check individual config files
    for file in "${config_files[@]}"; do
        if [[ -L "$file" ]]; then
            if [[ ! -e "$file" ]]; then
                broken_links+=("$file")
            else
                log_success "$(basename "$(dirname "$file")")/$(basename "$file") symlink is valid"
            fi
        elif [[ -f "$file" ]]; then
            log_warning "$(basename "$(dirname "$file")")/$(basename "$file") exists but is not a symlink"
        else
            log_warning "$(basename "$(dirname "$file")")/$(basename "$file") not found"
        fi
    done || true

    if [[ ${#broken_links[@]} -gt 0 ]]; then
        log_error "Found ${#broken_links[@]} broken symlinks:"
        for link in "${broken_links[@]}"; do
            echo "  - $link"
        done
    fi
}

check_shell_syntax() {
    log_info "Checking shell syntax..."

    local dotfiles_dir="${HOME}/.dotfiles"

    # Check main zshrc
    if zsh -n "$dotfiles_dir/zshrc" 2>/dev/null; then
        log_success "Main zshrc syntax is valid"
    else
        log_error "Main zshrc has syntax errors"
    fi

    # Check zsh modules
    if [[ -d "$dotfiles_dir/config/zsh" ]]; then
        for module in "$dotfiles_dir/config/zsh"/*.zsh; do
            if [[ -f "$module" ]]; then
                if zsh -n "$module" 2>/dev/null; then
                    log_success "$(basename "$module") syntax is valid"
                else
                    log_error "$(basename "$module") has syntax errors"
                fi
            fi
        done
    fi

    # Check shell scripts
    if [[ -d "$dotfiles_dir/scripts" ]]; then
        for script in "$dotfiles_dir/scripts"/*.sh; do
            if [[ -f "$script" ]]; then
                if bash -n "$script" 2>/dev/null; then
                    log_success "$(basename "$script") syntax is valid"
                else
                    log_error "$(basename "$script") has syntax errors"
                fi
            fi
        done
    fi
}

check_git_config() {
    log_info "Checking git configuration..."

    # Check if git user is configured
    if git config user.name >/dev/null 2>&1; then
        log_success "Git user.name is configured: $(git config user.name)"
    else
        log_error "Git user.name is not configured"
    fi

    if git config user.email >/dev/null 2>&1; then
        log_success "Git user.email is configured: $(git config user.email)"
    else
        log_error "Git user.email is not configured"
    fi

    # Check if global gitignore exists and is configured
    if git config core.excludesfile >/dev/null 2>&1; then
        local excludefile=$(git config core.excludesfile)
        # Expand ~ to home directory
        excludefile="${excludefile/#\~/$HOME}"
        if [[ -f "$excludefile" ]]; then
            log_success "Global gitignore is configured and exists"
        else
            log_error "Global gitignore is configured but file doesn't exist: $excludefile"
        fi
    else
        log_warning "Global gitignore is not configured"
    fi
}

check_homebrew() {
    log_info "Checking Homebrew setup..."

    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew is installed"

        # Check for outdated packages
        local outdated=$(brew outdated --quiet | wc -l | tr -d ' ')
        if [[ $outdated -gt 0 ]]; then
            log_warning "$outdated Homebrew packages are outdated"
        else
            log_success "All Homebrew packages are up to date"
        fi

        # Check Brewfile
        local dotfiles_dir="${HOME}/.dotfiles"
        if [[ -f "$dotfiles_dir/Brewfile" ]]; then
            log_success "Brewfile exists"
        else
            log_error "Brewfile not found"
        fi
    else
        log_error "Homebrew is not installed"
    fi
}

check_neovim_config() {
    log_info "Checking Neovim configuration..."

    if command -v nvim >/dev/null 2>&1; then
        log_success "Neovim is installed"

        # Check if config loads without errors
        if nvim --headless -c "lua vim.health.check()" -c "qa!" >/dev/null 2>&1; then
            log_success "Neovim configuration loads without errors"
        else
            log_warning "Neovim configuration may have issues (run :checkhealth)"
        fi
    else
        log_error "Neovim is not installed"
    fi
}

check_essential_tools() {
    log_info "Checking essential tools..."

    local tools=("git" "zsh" "starship" "eza" "bat" "nvim")

    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_success "$tool is installed"
        else
            log_error "$tool is not installed"
        fi
    done
}

print_summary() {
    echo
    echo "============================================================================"
    echo -e "${BLUE}Health Check Summary${NC}"
    echo "============================================================================"
    echo -e "✅ Successful checks: ${GREEN}$CHECKS${NC}"
    echo -e "⚠️  Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "❌ Issues: ${RED}$ISSUES${NC}"
    echo

    if [[ $ISSUES -eq 0 && $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All checks passed! Your dotfiles are healthy.${NC}"
        exit 0
    elif [[ $ISSUES -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  Some warnings found, but no critical issues.${NC}"
        exit 0
    else
        echo -e "${RED}❌ Found $ISSUES critical issues that need attention.${NC}"
        exit 1
    fi
}

main() {
    echo "============================================================================"
    echo -e "${BLUE}🏥 Dotfiles Health Check${NC}"
    echo "============================================================================"
    echo

    check_symlinks
    echo
    check_shell_syntax
    echo
    check_git_config
    echo
    check_homebrew
    echo
    check_neovim_config
    echo
    check_essential_tools

    print_summary
}

main "$@"