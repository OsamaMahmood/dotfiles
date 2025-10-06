#!/bin/bash

# Handle click event to open notification center
if [ "$1" = "click" ]; then
    # Use the configured notification center shortcut: Command+Shift+N
    osascript -e 'tell application "System Events" to keystroke "n" using {command down, shift down}' 2>/dev/null
    exit 0
fi

# Regular update - set the calendar label
sketchybar --set $NAME label="$(date +'%a %d %b %I:%M %p')"
