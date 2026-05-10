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
SKIP_CASKS=0
SKIP_SKETCHYBAR=0
ASSUME_YES=0

# Tool inventory — keep in sync with the configs that live in this repo.
BREW_FORMULAE=(
    jq
    curl
    btop
    micro
    gh
)

BREW_CASKS=(
    aerospace
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
    print_step "Updating Homebrew..."
    brew update >/dev/null 2>&1 || print_warning "brew update failed, continuing"
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

add_taps() {
    local taps=(FelixKratz/formulae)
    for tap in "${taps[@]}"; do
        if brew tap | grep -qx "$tap"; then
            continue
        fi
        print_step "Adding tap: $tap"
        brew tap "$tap" || print_warning "Failed to add tap $tap"
    done
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
    if brew list --cask "$pkg" &>/dev/null; then
        print_step "$pkg already installed"
    else
        print_step "Installing cask: $pkg..."
        brew install --cask "$pkg" && print_success "$pkg installed" \
            || print_warning "Failed to install $pkg"
    fi
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

start_aerospace() {
    if [[ $SKIP_CASKS -eq 1 ]]; then return; fi
    if pgrep -xq AeroSpace; then
        print_step "AeroSpace already running"
    else
        print_step "Launching AeroSpace..."
        open -a AeroSpace 2>/dev/null || print_warning "Could not auto-launch AeroSpace"
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
    # The sketchybar script has its own prompts; pipe yes if non-interactive
    if [[ $ASSUME_YES -eq 1 ]]; then
        yes | "$sb" || print_warning "SketchyBar installer reported errors"
    else
        "$sb" || print_warning "SketchyBar installer reported errors"
    fi
}

confirm() {
    [[ $ASSUME_YES -eq 1 ]] && return 0
    echo
    print_step "About to install:"
    echo "  formulae: ${BREW_FORMULAE[*]}"
    echo "  fonts:    ${BREW_FONTS[*]}"
    [[ $SKIP_CASKS -eq 0 ]] && echo "  casks:    ${BREW_CASKS[*]}"
    [[ $SKIP_SKETCHYBAR -eq 0 ]] && echo "  + SketchyBar (via install-sketchybar.sh)"
    echo
    read -p "Continue? (Y/n): " -n 1 -r reply
    echo
    [[ $reply =~ ^[Nn]$ ]] && { print_step "Cancelled"; exit 0; }
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

    add_taps
    install_brew_packages
    run_sketchybar_installer
    start_aerospace

    post_install_notes
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
