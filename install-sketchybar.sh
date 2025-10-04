#!/bin/bash

# SketchyBar Configuration Installer
# Automated setup script for SketchyBar with custom configuration
# Author: Osama Mahmood
# Repository: ~/.config
# Based on: https://felixkratz.github.io/SketchyBar/setup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_DIR="$HOME/.config/sketchybar"
PLUGINS_DIR="$CONFIG_DIR/plugins"
ITEMS_DIR="$CONFIG_DIR/items"
ICON_MAP_FN="$PLUGINS_DIR/icon_map_fn.sh"

# Font URLs and information
SKETCHYBAR_APP_FONT_URL="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.25/sketchybar-app-font.ttf"
SF_PRO_FONT_URL="https://developer.apple.com/design/downloads/SF-Pro.dmg"

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

handle_error() {
    local line_no=$1
    local error_code=$2
    print_error "Error occurred in script at line $line_no: (exit code $error_code)"
    print_error "Installation failed. Please check the error above and try again."
    exit $error_code
}

# Set up error handling
trap 'handle_error $LINENO $?' ERR

check_macos() {
    print_step "Checking operating system..."
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        print_error "Current OS: $OSTYPE"
        exit 1
    fi
    
    # Check macOS version
    local macos_version=$(sw_vers -productVersion)
    print_success "macOS $macos_version detected"
    
    # Check for "Displays have separate Spaces" setting
    print_warning "IMPORTANT: Ensure 'Displays have separate Spaces' is enabled in System Settings"
    print_step "Location: System Settings -> Desktop & Dock -> Displays have separate Spaces"
}

check_homebrew() {
    print_step "Checking for Homebrew..."
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install it first:"
        print_error "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        print_error "Visit: https://brew.sh"
        exit 1
    fi
    
    local brew_version=$(brew --version | head -n1)
    print_success "Homebrew found: $brew_version"
    
    # Update Homebrew
    print_step "Updating Homebrew..."
    if brew update; then
        print_success "Homebrew updated successfully"
    else
        print_warning "Failed to update Homebrew, continuing anyway..."
    fi
}

check_xcode_tools() {
    print_step "Checking for Xcode command line tools..."
    if ! xcode-select -p &> /dev/null; then
        print_warning "Xcode command line tools not found"
        print_step "Installing Xcode command line tools..."
        
        # Trigger installation
        if xcode-select --install 2>/dev/null; then
            print_step "Xcode command line tools installation started"
            print_step "Please complete the installation and run this script again"
            exit 0
        else
            print_warning "Xcode command line tools may already be installed or installation failed"
        fi
    else
        print_success "Xcode command line tools found"
    fi
}

install_dependencies() {
    print_step "Installing SketchyBar dependencies..."
    
    # Add required taps
    print_step "Adding Homebrew taps..."
    
    local taps=("homebrew/cask-fonts" "FelixKratz/formulae")
    for tap in "${taps[@]}"; do
        if brew tap "$tap" 2>/dev/null; then
            print_success "Added tap: $tap"
        else
            print_warning "Tap already exists or failed to add: $tap"
        fi
    done
    
    # Install core dependencies
    print_step "Installing core packages..."
    local packages=("sketchybar" "jq" "curl")
    
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_step "$package already installed"
        else
            print_step "Installing $package..."
            if brew install "$package"; then
                print_success "$package installed successfully"
            else
                print_error "Failed to install $package"
                exit 1
            fi
        fi
    done
    
    print_success "Core dependencies installed successfully"
}

install_fonts() {
    print_step "Installing required fonts..."
    
    # Install Hack Nerd Font (default SketchyBar font)
    if brew list --cask font-hack-nerd-font &>/dev/null; then
        print_step "font-hack-nerd-font already installed"
    else
        print_step "Installing Hack Nerd Font..."
        if brew install --cask font-hack-nerd-font; then
            print_success "Hack Nerd Font installed successfully"
        else
            print_warning "Failed to install Hack Nerd Font"
        fi
    fi

    # Install SF Pro (system font)
    if brew list font-sf-pro &>/dev/null; then
        print_step "font-sf-pro already installed"
    else
        print_step "Installing SF Pro Font..."
        if brew install font-sf-pro 2>/dev/null; then
            print_success "SF Pro Font installed successfully"
        else
            print_warning "Failed to install SF Pro Font via Homebrew"
            print_step "SF Pro Font may need to be downloaded manually from Apple Developer"
        fi
    fi

    # Install SF Symbols
    if brew list --cask sf-symbols &>/dev/null; then
        print_step "sf-symbols already installed"
    else
        print_step "Installing SF Symbols..."
        if brew install --cask sf-symbols; then
            print_success "SF Symbols installed successfully"
        else
            print_warning "Failed to install SF Symbols"
        fi
    fi

    # Install SketchyBar App Font
    local font_path="$HOME/Library/Fonts/sketchybar-app-font.ttf"
    if [[ -f "$font_path" ]]; then
        print_step "sketchybar-app-font already exists"
    else
        print_step "Installing SketchyBar App Font..."
        if install_sketchybar_font; then
            print_success "SketchyBar App Font installed successfully"
        else
            print_warning "Failed to install SketchyBar App Font"
        fi
    fi
    
    print_success "Font installation completed"
}

install_sketchybar_font() {
    local font_url="$SKETCHYBAR_APP_FONT_URL"
    local temp_dir=$(mktemp -d)
    local font_file="$temp_dir/sketchybar-app-font.ttf"
    local font_dest="$HOME/Library/Fonts/sketchybar-app-font.ttf"
    
    # Download the font
    if curl -fsSL "$font_url" -o "$font_file"; then
        # Install the font
        if cp "$font_file" "$font_dest"; then
            print_success "SketchyBar App Font downloaded and installed"
            rm -rf "$temp_dir"
            return 0
        else
            print_error "Failed to copy font to destination"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        print_error "Failed to download SketchyBar App Font"
        rm -rf "$temp_dir"
        return 1
    fi
}

install_icon_map() {
    print_step "Fetching latest icon_map.sh..."

    # Get latest release tag
    local latest_tag
    if latest_tag=$(curl -fsSL https://api.github.com/repos/kvndrsslr/sketchybar-app-font/releases/latest | jq -r .tag_name 2>/dev/null); then
        print_step "Latest release: $latest_tag"
    else
        print_warning "Failed to get latest release, using fallback"
        latest_tag="v2.0.25"
    fi

    # Create plugins directory
    mkdir -p "$PLUGINS_DIR"

    # Download icon_map.sh
    local icon_map_url="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/${latest_tag}/icon_map.sh"
    
    if curl -fsSL "$icon_map_url" -o "$ICON_MAP_FN"; then
        chmod +x "$ICON_MAP_FN"
        print_success "Downloaded latest icon_map.sh ($latest_tag)"
        return 0
    else
        print_warning "Failed to download icon_map.sh from GitHub release"
        
        # Fallback: try to get from main branch
        local fallback_url="https://raw.githubusercontent.com/kvndrsslr/sketchybar-app-font/main/icon_map.sh"
        if curl -fsSL "$fallback_url" -o "$ICON_MAP_FN"; then
            chmod +x "$ICON_MAP_FN"
            print_warning "Downloaded icon_map.sh from main branch (fallback)"
            return 0
        else
            print_error "Failed to download icon_map.sh from any source"
            return 1
        fi
    fi
}

setup_configuration() {
    print_step "Setting up SketchyBar configuration..."
    
    # Get the directory where this script is located
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local source_config_dir="$script_dir/sketchybar"
    
    # Check if source configuration exists
    if [[ ! -d "$source_config_dir" ]]; then
        print_error "SketchyBar configuration files not found in $source_config_dir"
        print_error "Please ensure you're running this script from the dotfiles directory"
        
        # Try to copy default configuration from brew
        print_step "Attempting to use default SketchyBar configuration..."
        if setup_default_configuration; then
            print_success "Default configuration set up successfully"
            return 0
        else
            print_error "Failed to set up any configuration"
            exit 1
        fi
    fi
    
    # Check if target configuration already exists
    if [[ -d "$CONFIG_DIR" ]]; then
        print_warning "SketchyBar configuration directory already exists at $CONFIG_DIR"
        read -p "Do you want to backup and replace it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local backup_dir="$CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
            if mv "$CONFIG_DIR" "$backup_dir"; then
                print_success "Existing configuration backed up to $backup_dir"
            else
                print_error "Failed to backup existing configuration"
                exit 1
            fi
        else
            print_step "Using existing configuration"
            return 0
        fi
    fi
    
    # Create the target directory
    mkdir -p "$CONFIG_DIR"
    
    # Copy all configuration files from source to target
    print_step "Copying configuration files from $source_config_dir to $CONFIG_DIR"
    if cp -r "$source_config_dir"/* "$CONFIG_DIR/"; then
        print_success "Configuration files copied successfully"
    else
        print_error "Failed to copy configuration files"
        exit 1
    fi
}

setup_default_configuration() {
    print_step "Setting up default SketchyBar configuration from brew..."
    
    local brew_prefix
    if brew_prefix=$(brew --prefix 2>/dev/null); then
        local example_config="$brew_prefix/share/sketchybar/examples"
        
        if [[ -d "$example_config" ]]; then
            mkdir -p "$CONFIG_DIR" "$PLUGINS_DIR"
            
            # Copy default configuration
            if cp "$example_config/sketchybarrc" "$CONFIG_DIR/sketchybarrc" && \
               cp -r "$example_config/plugins/"* "$PLUGINS_DIR/"; then
                print_success "Default configuration copied from brew examples"
                return 0
            else
                print_error "Failed to copy default configuration"
                return 1
            fi
        else
            print_error "Brew examples directory not found: $example_config"
            return 1
        fi
    else
        print_error "Failed to get brew prefix"
        return 1
    fi
}

setup_permissions() {
    print_step "Setting up file permissions..."
    
    # Make all shell scripts executable
    if find "$CONFIG_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null; then
        print_success "File permissions set correctly"
    else
        print_warning "Some files may not have correct permissions"
    fi
    
    # Make sketchybarrc executable
    if [[ -f "$CONFIG_DIR/sketchybarrc" ]]; then
        chmod +x "$CONFIG_DIR/sketchybarrc"
    fi
}

stop_existing_sketchybar() {
    print_step "Stopping any existing SketchyBar instances..."
    
    # Stop brew service if running
    if brew services stop sketchybar 2>/dev/null; then
        print_success "SketchyBar service stopped"
    else
        print_step "SketchyBar service was not running"
    fi
    
    # Kill any running SketchyBar processes
    if pkill -f sketchybar 2>/dev/null; then
        print_success "Stopped running SketchyBar processes"
        sleep 2
    else
        print_step "No running SketchyBar processes found"
    fi
}

start_sketchybar() {
    print_step "Starting SketchyBar..."
    
    # Verify configuration file exists
    if [[ ! -f "$CONFIG_DIR/sketchybarrc" ]]; then
        print_error "SketchyBar configuration file not found: $CONFIG_DIR/sketchybarrc"
        exit 1
    fi
    
    # Start SketchyBar service
    if brew services start sketchybar; then
        print_success "SketchyBar service started successfully"
        sleep 3
        
        # Verify it's running
        if pgrep -f sketchybar > /dev/null; then
            print_success "SketchyBar is running"
        else
            print_warning "SketchyBar service started but process not found"
        fi
    else
        print_warning "Failed to start SketchyBar service, trying manual start..."
        
        # Try manual start
        sketchybar --config "$CONFIG_DIR/sketchybarrc" &
        local sketchybar_pid=$!
        sleep 2
        
        if pgrep -f sketchybar > /dev/null; then
            print_success "SketchyBar started manually"
        else
            print_error "Failed to start SketchyBar manually"
            print_step "Try running 'sketchybar' in terminal to see error messages"
            exit 1
        fi
    fi
}

check_youtube_music() {
    print_step "Checking for YouTube Music Desktop..."
    
    if pgrep -f "YouTube Music" > /dev/null; then
        print_success "YouTube Music Desktop is running"
        
        # Test API connectivity
        if curl -s --max-time 2 localhost:26538/api/v1/song-info > /dev/null 2>&1; then
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

validate_installation() {
    print_step "Validating installation..."
    
    local errors=0
    
    # Check if SketchyBar is installed
    if ! command -v sketchybar &> /dev/null; then
        print_error "SketchyBar command not found"
        ((errors++))
    fi
    
    # Check if configuration exists
    if [[ ! -f "$CONFIG_DIR/sketchybarrc" ]]; then
        print_error "SketchyBar configuration file missing"
        ((errors++))
    fi
    
    # Check if SketchyBar is running
    if ! pgrep -f sketchybar > /dev/null; then
        print_warning "SketchyBar is not currently running"
    fi
    
    # Check if fonts are installed
    if [[ ! -f "$HOME/Library/Fonts/sketchybar-app-font.ttf" ]]; then
        print_warning "SketchyBar app font may not be installed"
    fi
    
    if [[ $errors -eq 0 ]]; then
        print_success "Installation validation passed"
        return 0
    else
        print_error "Installation validation failed with $errors errors"
        return 1
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
    echo -e "${BLUE}Configuration Details:${NC}"
    echo "• Config directory: $CONFIG_DIR"
    echo "• Plugins directory: $PLUGINS_DIR"
    echo "• Items directory: $ITEMS_DIR"
    echo
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Your SketchyBar should now be running with your custom configuration"
    echo "2. Hide the default macOS menu bar:"
    echo "   • System Settings -> Desktop & Dock -> Automatically hide and show the menu bar -> Always"
    echo "3. For music controls, install YouTube Music Desktop:"
    echo "   • Download from: https://github.com/ytmdesktop/ytmdesktop"
    echo "   • Enable API in settings (port 26538, no auth)"
    echo "4. Customize colors by editing: $CONFIG_DIR/colors.sh"
    echo "5. Load custom fonts: sketchybar --load-font <path-to-font>"
    echo
    echo -e "${BLUE}Control Commands:${NC}"
    echo "• Restart SketchyBar: brew services restart sketchybar"
    echo "• Stop SketchyBar: brew services stop sketchybar"
    echo "• Manual start: sketchybar"
    echo "• Custom config: sketchybar --config <path-to-config>"
    echo
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "• Check service status: brew services list | grep sketchybar"
    echo "• View logs: brew services list sketchybar"
    echo "• Debug mode: sketchybar (to see error messages)"
    echo "• Reload config: sketchybar --reload"
    echo "• Configuration file: $CONFIG_DIR/sketchybarrc"
    echo
    echo -e "${BLUE}Important Settings:${NC}"
    echo "• Ensure 'Displays have separate Spaces' is enabled"
    echo "• Location: System Settings -> Desktop & Dock"
    echo
    echo -e "${BLUE}Enjoy your new status bar! 🚀${NC}"
    echo
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        print_error "Installation failed. Cleaning up..."
        # Stop any SketchyBar processes that might be running
        pkill -f sketchybar 2>/dev/null || true
        brew services stop sketchybar 2>/dev/null || true
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Main installation process
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              SketchyBar Configuration Installer               ║${NC}"
    echo -e "${BLUE}║                     Custom Setup Script                      ║${NC}"
    echo -e "${BLUE}║                  https://felixkratz.github.io/SketchyBar/     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Pre-installation checks
    check_macos
    check_homebrew
    check_xcode_tools
    
    # Confirm installation
    print_step "This script will install and configure SketchyBar with custom settings"
    print_warning "This will modify your system and install packages via Homebrew"
    echo
    read -p "Continue with installation? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_step "Installation cancelled by user"
        exit 0
    fi
    
    echo
    print_step "Starting SketchyBar installation..."
    echo
    
    # Installation steps
    install_dependencies
    install_fonts
    install_icon_map
    setup_configuration
    setup_permissions
    stop_existing_sketchybar
    start_sketchybar
    
    # Post-installation checks and validation
    check_youtube_music
    
    if validate_installation; then
        # Display completion message
        display_post_install_info
    else
        print_error "Installation completed with warnings. Please check the issues above."
        exit 1
    fi
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    main "$@"
else
    # Script is being sourced
    print_warning "Script is being sourced. Run 'main' function to start installation."
fi
