#!/usr/bin/env bash
# ============================================================================
# Dotfiles Backup Script
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="${HOME}/.dotfiles"
BACKUP_BASE_DIR="${HOME}/.dotfiles-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${BACKUP_BASE_DIR}/${TIMESTAMP}"

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

create_backup() {
    log_info "Creating backup of dotfiles..."

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

    # Backup the entire dotfiles directory
    log_info "Copying dotfiles directory..."
    cp -R "$DOTFILES_DIR" "$BACKUP_DIR/dotfiles"

    # Backup current symlinks state
    log_info "Backing up current symlink states..."
    mkdir -p "$BACKUP_DIR/symlinks"

    # List of common dotfiles to check
    local dotfiles=(
        ".zshrc"
        ".zshenv"
        ".gitconfig"
        ".gitmessage"
        ".gitignore_global"
        ".vimrc"
        ".psqlrc"
    )

    for file in "${dotfiles[@]}"; do
        local filepath="${HOME}/${file}"
        if [[ -L "$filepath" ]]; then
            # It's a symlink, record where it points
            readlink "$filepath" > "$BACKUP_DIR/symlinks/${file}.link" 2>/dev/null || true
        elif [[ -f "$filepath" ]]; then
            # It's a regular file, back it up
            cp "$filepath" "$BACKUP_DIR/symlinks/${file}.backup" 2>/dev/null || true
        fi
    done

    # Backup config directories state
    log_info "Backing up config directories state..."
    mkdir -p "$BACKUP_DIR/config"

    local config_dirs=(
        "nvim"
        "kitty"
        "yazi"
        "aerospace"
        "tmux"
        "bat"
    )

    for dir in "${config_dirs[@]}"; do
        local configpath="${HOME}/.config/${dir}"
        if [[ -L "$configpath" ]]; then
            # It's a symlink, record where it points
            readlink "$configpath" > "$BACKUP_DIR/config/${dir}.link" 2>/dev/null || true
        elif [[ -d "$configpath" ]]; then
            # It's a directory, back it up
            cp -R "$configpath" "$BACKUP_DIR/config/${dir}.backup" 2>/dev/null || true
        fi
    done

    # Create backup manifest
    create_manifest

    log_success "Backup created: $BACKUP_DIR"
}

create_manifest() {
    log_info "Creating backup manifest..."

    local manifest_file="$BACKUP_DIR/MANIFEST.md"

    cat > "$manifest_file" << EOF
# Dotfiles Backup Manifest

**Created:** $(date)
**Backup Directory:** $BACKUP_DIR

## Contents

### Dotfiles Repository
- Location: \`dotfiles/\`
- Original: \`$DOTFILES_DIR\`

### Symlinks State
- Location: \`symlinks/\`
- Contains current state of all dotfile symlinks

### Config Directories State
- Location: \`config/\`
- Contains current state of all config directory symlinks

## File Types

- \`.link\` files contain the target path of symlinks
- \`.backup\` files are copies of regular files/directories

## Restoration

To restore from this backup:

1. Remove current symlinks:
   \`\`\`bash
   # Remove symlinks carefully
   unlink ~/.zshrc 2>/dev/null || true
   unlink ~/.gitconfig 2>/dev/null || true
   # ... etc for other files
   \`\`\`

2. Copy dotfiles repository:
   \`\`\`bash
   cp -R $BACKUP_DIR/dotfiles ~/.dotfiles
   \`\`\`

3. Run dotbot to recreate symlinks:
   \`\`\`bash
   cd ~/.dotfiles
   dotbot -c install.conf.yaml
   \`\`\`

## System Information

- **Hostname:** $(hostname)
- **User:** $(whoami)
- **OS:** $(uname -s)
- **Shell:** $SHELL

## Git Status (if available)

EOF

    # Add git status if in a git repository
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        cd "$DOTFILES_DIR"
        echo "\`\`\`" >> "$manifest_file"
        git status >> "$manifest_file" 2>/dev/null || echo "Could not get git status" >> "$manifest_file"
        echo "\`\`\`" >> "$manifest_file"
        echo "" >> "$manifest_file"

        echo "**Last commit:**" >> "$manifest_file"
        echo "\`\`\`" >> "$manifest_file"
        git log -1 --oneline >> "$manifest_file" 2>/dev/null || echo "Could not get last commit" >> "$manifest_file"
        echo "\`\`\`" >> "$manifest_file"
    fi

    log_success "Manifest created: $manifest_file"
}

cleanup_old_backups() {
    local keep_days=${1:-7}

    log_info "Cleaning up backups older than $keep_days days..."

    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        log_info "No backup directory found, nothing to clean"
        return 0
    fi

    local cleaned=0
    while IFS= read -r -d '' backup_dir; do
        if [[ -d "$backup_dir" ]]; then
            ((cleaned++))
            rm -rf "$backup_dir"
            log_info "Removed old backup: $(basename "$backup_dir")"
        fi
    done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -mtime +$keep_days -print0)

    if [[ $cleaned -eq 0 ]]; then
        log_info "No old backups to clean"
    else
        log_success "Cleaned up $cleaned old backups"
    fi
}

list_backups() {
    log_info "Available backups:"

    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        log_warning "No backup directory found"
        return 1
    fi

    local count=0
    for backup in "$BACKUP_BASE_DIR"/*; do
        if [[ -d "$backup" ]]; then
            local backup_name=$(basename "$backup")
            local backup_date=$(echo "$backup_name" | sed 's/_/ /' | sed 's/\(..\)\(..\)\(..\)_\(..\)\(..\)\(..\)/20\1-\2-\3 \4:\5:\6/')
            echo "  📁 $backup_name ($backup_date)"

            # Show size
            local size=$(du -sh "$backup" | cut -f1)
            echo "     Size: $size"

            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        log_warning "No backups found"
    else
        log_info "Total backups: $count"
    fi
}

restore_backup() {
    local backup_timestamp="$1"
    local restore_dir="${BACKUP_BASE_DIR}/${backup_timestamp}"

    if [[ ! -d "$restore_dir" ]]; then
        log_error "Backup not found: $restore_dir"
        return 1
    fi

    log_warning "This will replace your current dotfiles!"
    echo -n "Continue? [y/N] "
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Restore cancelled"
        return 0
    fi

    log_info "Restoring from backup: $backup_timestamp"

    # Create a backup of current state first
    log_info "Creating backup of current state before restore..."
    create_backup

    # Remove current dotfiles (backup was just created)
    if [[ -d "$DOTFILES_DIR" ]]; then
        rm -rf "$DOTFILES_DIR"
    fi

    # Restore dotfiles directory
    cp -R "$restore_dir/dotfiles" "$DOTFILES_DIR"

    # Run dotbot to recreate symlinks
    cd "$DOTFILES_DIR"
    if [[ -f "install.conf.yaml" ]]; then
        log_info "Running dotbot to recreate symlinks..."
        dotbot -c install.conf.yaml
        log_success "Restore completed!"
    else
        log_error "install.conf.yaml not found in backup"
        return 1
    fi
}

print_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  backup               Create a new backup (default)"
    echo "  list                 List available backups"
    echo "  restore TIMESTAMP    Restore from backup"
    echo "  cleanup [DAYS]       Remove backups older than DAYS (default: 7)"
    echo
    echo "Examples:"
    echo "  $0                           # Create backup"
    echo "  $0 list                      # List backups"
    echo "  $0 restore 20241201_143022   # Restore specific backup"
    echo "  $0 cleanup 14                # Remove backups older than 14 days"
}

main() {
    case "${1:-backup}" in
        "backup"|"create")
            echo "============================================================================"
            echo -e "${BLUE}📦 Creating Dotfiles Backup${NC}"
            echo "============================================================================"
            create_backup
            cleanup_old_backups
            ;;
        "list")
            list_backups
            ;;
        "restore")
            if [[ $# -lt 2 ]]; then
                log_error "Please specify backup timestamp"
                echo "Available backups:"
                list_backups
                exit 1
            fi
            restore_backup "$2"
            ;;
        "cleanup")
            cleanup_old_backups "${2:-7}"
            ;;
        "help"|"-h"|"--help")
            print_usage
            ;;
        *)
            log_error "Unknown command: $1"
            print_usage
            exit 1
            ;;
    esac
}

main "$@"