#!/bin/bash

# SketchyBar Configuration Installer
# Automated setup script for SketchyBar with custom configuration
# Author: Osama Mahmood
# Repository: ~/.config

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_DIR="$HOME/.config/sketchybar"
FONT_DIR="$HOME/Library/Fonts"
FONT_URL="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.45/sketchybar-app-font.ttf"
FONT_NAME="sketchybar-app-font.ttf"

# Helper functions
print_step() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_success "macOS detected"
}

check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install it first:"
        echo "Visit: https://brew.sh"
        exit 1
    fi
    print_success "Homebrew found"
}

install_dependencies() {
    print_step "Installing SketchyBar dependencies..."
    
    # Add required taps
    print_step "Adding Homebrew taps..."
    brew tap homebrew/cask-fonts 2>/dev/null || print_warning "cask-fonts tap already exists"
    brew tap FelixKratz/formulae 2>/dev/null || print_warning "FelixKratz/formulae tap already exists"
    
    # Install core dependencies
    print_step "Installing core packages..."
    brew install sketchybar jq curl
    
    # Install fonts
    print_step "Installing fonts..."
    brew install --cask font-hack-nerd-font
    brew install font-sf-pro
    brew install --cask sf-symbols
    
    print_success "Dependencies installed successfully"
}

install_custom_font() {
    print_step "Installing SketchyBar App Font..."
    
    # Create fonts directory if it doesn't exist
    mkdir -p "$FONT_DIR"
    
    # Download and install the custom font
    if curl -L "$FONT_URL" -o "$FONT_DIR/$FONT_NAME"; then
        print_success "SketchyBar App Font installed successfully"
    else
        print_error "Failed to download SketchyBar App Font"
        exit 1
    fi
}

setup_configuration() {
    print_step "Setting up SketchyBar configuration..."
    
    # Check if configuration already exists
    if [[ -d "$CONFIG_DIR" ]]; then
        print_warning "SketchyBar configuration directory already exists"
        read -p "Do you want to backup and replace it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$CONFIG_DIR" "$CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
            print_success "Existing configuration backed up"
        else
            print_step "Using existing configuration"
            return 0
        fi
    fi
    
    # The configuration files should already be in place if running from ~/.config
    if [[ ! -d "$HOME/.config/sketchybar" ]]; then
        print_error "SketchyBar configuration files not found in ~/.config/sketchybar"
        print_error "Please ensure you're running this script from the correct location"
        exit 1
    fi
    
    print_success "Configuration files are ready"
}

setup_permissions() {
    print_step "Setting up file permissions..."
    
    # Make all shell scripts executable
    find "$CONFIG_DIR" -name "*.sh" -exec chmod +x {} \;
    
    print_success "File permissions set correctly"
}

stop_existing_sketchybar() {
    print_step "Stopping any existing SketchyBar instances..."
    
    # Stop brew service if running
    brew services stop sketchybar 2>/dev/null || print_warning "SketchyBar service was not running"
    
    # Kill any running SketchyBar processes
    pkill -f sketchybar 2>/dev/null || print_warning "No running SketchyBar processes found"
    
    sleep 2
    print_success "Existing SketchyBar instances stopped"
}

start_sketchybar() {
    print_step "Starting SketchyBar..."
    
    # Start SketchyBar service
    if brew services start sketchybar; then
        print_success "SketchyBar service started successfully"
    else
        print_error "Failed to start SketchyBar service"
        print_step "Trying to start manually..."
        sketchybar &
        sleep 2
        if pgrep -f sketchybar > /dev/null; then
            print_success "SketchyBar started manually"
        else
            print_error "Failed to start SketchyBar"
            exit 1
        fi
    fi
}

check_youtube_music() {
    print_step "Checking for YouTube Music Desktop..."
    
    if pgrep -f "YouTube Music" > /dev/null; then
        print_success "YouTube Music Desktop is running"
        
        # Test API connectivity
        if curl -s --max-time 2 localhost:26538/api/v1/song-info > /dev/null; then
            print_success "YouTube Music API is accessible"
        else
            print_warning "YouTube Music API is not accessible on port 26538"
            print_step "Please ensure API is enabled in YouTube Music Desktop settings"
        fi
    else
        print_warning "YouTube Music Desktop is not running"
        print_step "Music controls will not work without YouTube Music Desktop"
    fi
}

display_post_install_info() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 Installation Complete! 🎉                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    print_success "SketchyBar has been installed and configured successfully!"
    echo
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Your SketchyBar should now be running with your custom configuration"
    echo "2. For music controls, install YouTube Music Desktop:"
    echo "   • Download from: https://github.com/ytmdesktop/ytmdesktop"
    echo "   • Enable API in settings (port 26538, no auth)"
    echo "3. Customize colors by editing: ~/.config/sketchybar/colors.sh"
    echo "4. Restart SketchyBar: brew services restart sketchybar"
    echo
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "• Check logs: brew services list | grep sketchybar"
    echo "• Manual start: sketchybar (to see error messages)"
    echo "• Configuration: ~/.config/sketchybar/sketchybarrc"
    echo
    echo -e "${BLUE}Enjoy your new status bar! 🚀${NC}"
    echo
}

# Main installation process
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              SketchyBar Configuration Installer               ║${NC}"
    echo -e "${BLUE}║                     Custom Setup Script                      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Pre-installation checks
    check_macos
    check_homebrew
    
    # Confirm installation
    print_step "This script will install and configure SketchyBar with custom settings"
    read -p "Continue with installation? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_step "Installation cancelled by user"
        exit 0
    fi
    
    # Installation steps
    install_dependencies
    install_custom_font
    setup_configuration
    setup_permissions
    stop_existing_sketchybar
    start_sketchybar
    
    # Post-installation checks
    check_youtube_music
    
    # Display completion message
    display_post_install_info
}

# Run main function
main "$@"
