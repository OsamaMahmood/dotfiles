# Configuration Files

This repository contains my personal configuration files for various development tools and applications on macOS.

## 📋 Table of Contents

- [SketchyBar](#-sketchybar)
- [Warp Terminal](#-warp-terminal)
- [Ghostty Terminal](#-ghostty-terminal)
- [Micro Editor](#-micro-editor)

---

## 🎨 SketchyBar

SketchyBar is a highly customizable macOS status bar replacement that provides system information and custom widgets. This configuration features a unified pill design with blur effects and comprehensive system monitoring.

### Configuration Structure

```
sketchybar/
├── sketchybarrc          # Main configuration file
├── colors.sh            # Color scheme definitions (Catppuccin Mocha)
├── items/               # Individual status bar items
│   ├── apple_logo.sh
│   ├── battery.sh
│   ├── calendar.sh
│   ├── cpu.sh
│   ├── front_app.sh
│   ├── memory.sh
│   ├── music.sh
│   ├── spaces.sh
│   └── volume.sh
└── plugins/             # Plugin scripts for dynamic content
    ├── apple_menu.sh
    ├── battery.sh
    ├── calendar.sh
    ├── cpu.sh
    ├── front_app.sh
    ├── icon_map_fn.sh
    ├── memory.sh
    ├── music_helpers.sh
    ├── space_windows.sh
    ├── space.sh
    ├── volume.sh
    ├── youtube-music-click-handler.sh
    ├── youtube-music-fast-toggle.sh
    └── youtube-music.sh

# Root configuration includes
install-sketchybar.sh     # Automated installer script
```

### Features

- **System Monitoring**: Real-time CPU and memory usage with optimized performance calculations
- **Battery Management**: Intelligent battery status with charging indicators using SF Symbols
- **Media Controls**: Advanced YouTube Music integration with API connectivity and control buttons
- **Workspace Management**: 10 configurable spaces with custom app font icons
- **Custom Styling**: Catppuccin Mocha color scheme with unified pill backgrounds and blur effects
- **Responsive Design**: Dynamic show/hide functionality based on app states

### Dependencies

#### Required Tools

```bash
# Core dependencies
- brew

YouTube Music Desktop App (for music integration)
Install from: https://github.com/ytmdesktop/ytmdesktop
```

#### Required Fonts

- **SF Pro**: System font (included with macOS)
- **SketchyBar App Font**: Custom font for space icons
  ```bash
  # Install the font from SketchyBar's font collection
  curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.45/sketchybar-app-font.ttf -o ~/Library/Fonts/sketchybar-app-font.ttf
  ```

#### System Requirements

- **macOS System Tools**: `sysctl`, `ps`, `vm_stat`, `pmset` (built-in)
- **YouTube Music Desktop with API**: Must be running on port 26538 for music controls
- **SF Symbols**: Used for battery, volume, and UI icons (built-in)

### Quick Setup (Automated)

**🚀 One-Command Installation:**

```bash
cd ~/.config && ./install-sketchybar.sh
```

The installer script will automatically:

- Install all dependencies and fonts
- Set up proper permissions
- Start SketchyBar service
- Check for YouTube Music integration
- Provide troubleshooting guidance

### Manual Setup

1. **Install SketchyBar and dependencies**:

   ```bash
   brew tap homebrew/cask-fonts
   brew tap FelixKratz/formulae
   brew install sketchybar jq curl
   brew install --cask font-hack-nerd-font
   brew install font-sf-pro
   brew install --cask sf-symbols
   ```

2. **Install the custom font**:

   ```bash
   curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.45/sketchybar-app-font.ttf -o ~/Library/Fonts/sketchybar-app-font.ttf
   ```

3. **Install YouTube Music Desktop** (optional, for music controls):

   - Download from [ytmdesktop releases](https://github.com/ytmdesktop/ytmdesktop)
   - Enable API in settings and change API config to no auth(port 26538)

4. **Link the configuration**:

   ```bash
   ln -sf ~/.config/sketchybar ~/.config/sketchybar
   ```

5. **Start SketchyBar**:
   ```bash
   brew services start sketchybar
   ```

### Configuration Reference

This setup follows the [official SketchyBar documentation](https://felixkratz.github.io/SketchyBar/config/bar) with custom optimizations for:

- Reduced API timeouts for better performance
- Unified pill backgrounds with blur effects
- Catppuccin Mocha color integration
- Error handling for external dependencies

---

## 🚀 Warp Terminal

Warp is a modern, Rust-based terminal with AI integration and collaborative features.

### Configuration Structure

```
warp/
└── themes/
    ├── catppuccin_frappe.yml
    ├── catppuccin_latte.yml
    ├── catppuccin_macchiato.yml
    └── catppuccin_mocha.yml
```

### Features

- **Custom Themes**: Full Catppuccin color scheme collection
- **Modern Interface**: Block-based command editing and AI assistance
- **Performance**: Fast, GPU-accelerated rendering

### Theme Variants

- **Mocha**: Dark theme with warm tones
- **Macchiato**: Medium dark theme
- **Frappe**: Medium theme
- **Latte**: Light theme

---

## 👻 Ghostty Terminal

Ghostty is a fast, feature-rich terminal emulator written in Zig.

### Configuration Structure

```
ghostty/
├── config                    # Main configuration file
└── themes/
    └── catppuccin-mocha.conf # Custom theme configuration
```

### Features

- **High Performance**: Written in Zig for maximum speed
- **Customizable**: Extensive configuration options
- **Theme Support**: Catppuccin Mocha theme integration

### Setup

1. Install Ghostty from the official website
2. The configuration will be automatically detected in `~/.config/ghostty/`

---

## ✏️ Micro Editor

Micro is a modern and intuitive terminal-based text editor.

### Configuration Structure

```
micro/
├── backups/        # Automatic backup files
├── bindings.json   # Custom key bindings
└── buffers/
    └── history     # Command and search history
```

### Features

- **Modern Interface**: Mouse support and syntax highlighting
- **Customizable**: Custom key bindings and plugins
- **Backup System**: Automatic file backups for safety

### Key Features

- Syntax highlighting for 100+ languages
- Mouse support
- Plugin system
- Multiple cursors
- Auto-backup functionality

---

## 🔧 Installation & Setup

1. **Clone the repository**:

   ```bash
   git clone <repository-url> ~/.config
   ```

2. **Install dependencies**:

   ```bash
   # Core tools
   brew install sketchybar micro

   # Terminal emulators
   brew install --cask warp
   # Install Ghostty from official website
   ```

3. **Link configurations**:
   Most configurations are automatically detected when placed in `~/.config/`.

4. **Restart services**:
   ```bash
   brew services restart sketchybar
   ```

## 📝 Notes

- Themes follow the Catppuccin color scheme for consistency across all tools
- All configurations are optimized for macOS development workflow
- Only actively maintained and tracked configurations are documented here

## 🤝 Contributing

Feel free to suggest improvements or report issues with any of these configurations.

---

_Last updated: October 4, 2025_
