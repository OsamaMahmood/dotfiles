#!/bin/bash

# Dotfiles installer for ~/.config
# Installs all CLI tools, casks, and fonts referenced by the configs in this
# repo, then activates them. Configurations themselves already live in this
# directory tree, so no symlinking is required — the tools auto-discover them.
#
# Usage:
#   ./install.sh              # full install (interactive confirmation)
#   ./install.sh --yes        # skip confirmation
#   ./install.sh --skip-casks # only install CLI formulae + fonts
#   ./install.sh --no-sketchybar
#   ./install.sh --help

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG="$HOME/.config"
SKIP_CASKS=0
SKIP_SKETCHYBAR=0
ASSUME_YES=0

# Configs to copy from this repo into ~/.config when the repo is cloned
# somewhere other than ~/.config itself. Sketchybar is intentionally excluded
# — install-sketchybar.sh handles its own copy.
SYNC_DIRS=(aerospace git)
SYNC_FILES=(micro/bindings.json)

# Tool inventory — keep in sync with the configs that live in this repo.
BREW_FORMULAE=(
    jq
    curl
    btop
    micro
    gh
)

BREW_CASKS=(
    nikitabobko/tap/aerospace
    raycast
    ngrok
    google-cloud-sdk
)

BREW_FONTS=(
    font-hack-nerd-font
    font-sf-pro
    sf-symbols
)

print_step()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERR]${NC} $1"; }

usage() {
    grep -E '^# ' "$0" | sed -E 's/^# ?//' | head -n 12
    exit 0
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            -y|--yes)            ASSUME_YES=1 ;;
            --skip-casks)        SKIP_CASKS=1 ;;
            --no-sketchybar)     SKIP_SKETCHYBAR=1 ;;
            -h|--help)           usage ;;
            *)                   print_warning "Unknown argument: $arg" ;;
        esac
    done
}

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This installer is macOS-only (detected: $OSTYPE)"
        exit 1
    fi
    print_success "macOS $(sw_vers -productVersion)"
}

check_homebrew() {
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew is required. Install it first:"
        print_error '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    print_success "Homebrew $(brew --version | head -n1 | awk '{print $2}')"
}

check_xcode_tools() {
    if ! xcode-select -p &>/dev/null; then
        print_warning "Xcode CLT not found, triggering installer"
        xcode-select --install 2>/dev/null || true
        print_step "Re-run this script once Xcode CLT finishes installing"
        exit 0
    fi
    print_success "Xcode command line tools present"
}

install_formula() {
    local pkg="$1"
    if brew list --formula "$pkg" &>/dev/null; then
        print_step "$pkg already installed"
    else
        print_step "Installing $pkg..."
        brew install "$pkg" && print_success "$pkg installed" \
            || print_warning "Failed to install $pkg"
    fi
}

install_cask() {
    local pkg="$1"
    # Strip tap prefix when checking if installed (brew list takes the short name)
    local short="${pkg##*/}"
    if brew list --cask "$short" &>/dev/null; then
        print_step "$short already installed"
        return
    fi

    print_step "Installing cask: $pkg..."
    local log; log="$(mktemp)"
    if brew install --cask "$pkg" 2>&1 | tee "$log"; then
        if grep -q "successfully installed" "$log" 2>/dev/null \
                || brew list --cask "$short" &>/dev/null; then
            print_success "$pkg installed"
            rm -f "$log"
            return
        fi
    fi

    # Workaround for Homebrew API bug: "undefined method 'to_sym' for nil"
    if grep -q "to_sym" "$log" 2>/dev/null; then
        print_warning "Hit Homebrew API bug, retrying with HOMEBREW_NO_INSTALL_FROM_API=1..."
        if HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask "$pkg"; then
            print_success "$pkg installed (via no-API fallback)"
            rm -f "$log"
            return
        fi
    fi

    print_warning "Failed to install $pkg"
    rm -f "$log"
}

install_brew_packages() {
    print_step "Installing CLI formulae..."
    for pkg in "${BREW_FORMULAE[@]}"; do
        install_formula "$pkg"
    done

    print_step "Installing fonts..."
    for pkg in "${BREW_FONTS[@]}"; do
        install_cask "$pkg"
    done

    if [[ $SKIP_CASKS -eq 1 ]]; then
        print_warning "Skipping GUI casks (--skip-casks)"
        return
    fi
    print_step "Installing GUI casks..."
    for pkg in "${BREW_CASKS[@]}"; do
        install_cask "$pkg"
    done
}

sync_configs() {
    if [[ "$SCRIPT_DIR" == "$TARGET_CONFIG" ]]; then
        print_step "Repo is already at $TARGET_CONFIG — no sync needed"
        return
    fi

    print_step "Copying configs from $SCRIPT_DIR → $TARGET_CONFIG"
    mkdir -p "$TARGET_CONFIG"
    local stamp
    stamp="$(date +%Y%m%d_%H%M%S)"

    for item in "${SYNC_DIRS[@]}"; do
        local src="$SCRIPT_DIR/$item"
        local dst="$TARGET_CONFIG/$item"
        [[ -d "$src" ]] || continue
        if [[ -e "$dst" ]]; then
            local backup="${dst}.backup.${stamp}"
            mv "$dst" "$backup"
            print_warning "Backed up existing $item → $(basename "$backup")"
        fi
        cp -R "$src" "$dst" && print_success "Copied $item/"
    done

    for rel in "${SYNC_FILES[@]}"; do
        local src="$SCRIPT_DIR/$rel"
        local dst="$TARGET_CONFIG/$rel"
        [[ -f "$src" ]] || continue
        mkdir -p "$(dirname "$dst")"
        if [[ -e "$dst" ]]; then
            cp "$dst" "${dst}.backup.${stamp}"
            print_warning "Backed up existing $rel"
        fi
        cp "$src" "$dst" && print_success "Copied $rel"
    done
}

start_aerospace() {
    if [[ $SKIP_CASKS -eq 1 ]]; then return; fi

    if pgrep -xq AeroSpace; then
        print_step "AeroSpace already running, reloading config..."
    else
        print_step "Launching AeroSpace..."
        open -a AeroSpace 2>/dev/null || {
            print_warning "Could not auto-launch AeroSpace"
            return
        }
    fi

    # Wait for it to come up, then reload the config from this repo
    local tries=0
    until pgrep -xq AeroSpace || [[ $tries -ge 10 ]]; do
        sleep 1
        ((tries++))
    done

    if ! pgrep -xq AeroSpace; then
        print_warning "AeroSpace did not start within 10s — check Accessibility permissions"
        return
    fi

    if command -v aerospace &>/dev/null; then
        aerospace reload-config 2>/dev/null \
            && print_success "AeroSpace running, config reloaded" \
            || print_warning "AeroSpace running but reload-config failed (config may have errors)"
    else
        print_success "AeroSpace running"
    fi
}

run_sketchybar_installer() {
    if [[ $SKIP_SKETCHYBAR -eq 1 ]]; then
        print_warning "Skipping SketchyBar setup (--no-sketchybar)"
        return
    fi
    local sb="$SCRIPT_DIR/install-sketchybar.sh"
    if [[ ! -x "$sb" ]]; then
        print_warning "install-sketchybar.sh not found or not executable; skipping"
        return
    fi
    print_step "Running SketchyBar installer..."
    # Note: install-sketchybar.sh uses `read -n 1` which consumes a single byte
    # per prompt. Piping plain `yes` would feed `y\ny\n…` and the second read
    # would land on `\n` (empty). Strip newlines so every read sees `y`.
    if [[ $ASSUME_YES -eq 1 ]]; then
        yes | tr -d '\n' | "$sb" || print_warning "SketchyBar installer reported errors"
    else
        "$sb" || print_warning "SketchyBar installer reported errors"
    fi

    # Force a reload so any local edits to sketchybarrc are picked up
    if command -v sketchybar &>/dev/null && pgrep -xq sketchybar; then
        sketchybar --reload 2>/dev/null \
            && print_success "SketchyBar reloaded" \
            || print_warning "sketchybar --reload failed"
    fi
}

verify_runtime() {
    echo
    print_step "Verifying tools are loaded..."
    local failed=0

    # CLI tools — just check they're on PATH
    local clis=(jq btop micro gh)
    for cli in "${clis[@]}"; do
        if command -v "$cli" &>/dev/null; then
            print_success "$cli on PATH ($(command -v $cli))"
        else
            print_error "$cli not found on PATH"
            ((failed++))
        fi
    done

    # SketchyBar — must be a running process
    if [[ $SKIP_SKETCHYBAR -eq 0 ]]; then
        if pgrep -xq sketchybar; then
            print_success "sketchybar process running"
        else
            print_error "sketchybar is NOT running"
            ((failed++))
        fi
    fi

    # AeroSpace — must be a running process
    if [[ $SKIP_CASKS -eq 0 ]]; then
        if pgrep -xq AeroSpace; then
            print_success "AeroSpace process running"
        else
            print_error "AeroSpace is NOT running"
            ((failed++))
        fi
    fi

    if [[ $failed -gt 0 ]]; then
        print_warning "$failed verification check(s) failed — see messages above"
        return 1
    fi
    print_success "All verification checks passed"
}

confirm() {
    [[ $ASSUME_YES -eq 1 ]] && return 0
    echo
    print_step "About to install:"
    echo "  formulae: ${BREW_FORMULAE[*]}"
    echo "  fonts:    ${BREW_FONTS[*]}"
    [[ $SKIP_CASKS -eq 0 ]] && echo "  casks:    ${BREW_CASKS[*]}"
    [[ $SKIP_SKETCHYBAR -eq 0 ]] && echo "  + SketchyBar (via install-sketchybar.sh)"
    if [[ "$SCRIPT_DIR" != "$TARGET_CONFIG" ]]; then
        echo "  + copy configs to $TARGET_CONFIG: ${SYNC_DIRS[*]} ${SYNC_FILES[*]}"
    fi
    echo
    read -p "Continue? (Y/n): " -n 1 -r reply
    echo
    if [[ $reply =~ ^[Nn]$ ]]; then
        print_step "Cancelled"
        exit 0
    fi
    return 0
}

post_install_notes() {
    echo
    echo -e "${GREEN}Done.${NC} Manual follow-ups (one-time auth, not scripted):"
    echo "  • gh auth login                        # GitHub CLI"
    echo "  • gcloud init                          # Google Cloud SDK"
    echo "  • ngrok config add-authtoken <TOKEN>   # ngrok"
    echo "  • Open Raycast and grant Accessibility permissions"
    echo "  • Open AeroSpace and grant Accessibility permissions"
    echo
    echo "Configs in this repo are already in ~/.config — no symlinks needed."
    echo "Restart any tool that was running before this install."
}

main() {
    parse_args "$@"

    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}  ~/.config dotfiles installer${NC}"
    echo -e "${BLUE}===============================================${NC}"

    check_macos
    check_homebrew
    check_xcode_tools
    confirm

    install_brew_packages
    sync_configs
    run_sketchybar_installer
    start_aerospace
    verify_runtime || true

    post_install_notes
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
