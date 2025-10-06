#!/bin/bash

source "$CONFIG_DIR/colors.sh" # Loads all defined colors

# Handle mouse click - lock the system
if [ "$SENDER" = "mouse.clicked" ]; then
    # Lock the system using Command+Control+Q
    osascript -e 'tell application "System Events" to keystroke "q" using {command down, control down}' 2>/dev/null
    exit 0
fi

# Handle mouse hover effects
if [ "$SENDER" = "mouse.entered" ]; then
    # Brighter red background on hover with white icon
    sketchybar --set $NAME background.drawing=on \
                           background.color=0xaaf38ba8 \
                           icon.color=$WHITE
fi

if [ "$SENDER" = "mouse.exited" ]; then
    # Return to normal red icon with default background
    sketchybar --set $NAME background.drawing=on \
                           background.color=$ITEM_BG_COLOR \
                           icon.color=0xfff38ba8
fi
