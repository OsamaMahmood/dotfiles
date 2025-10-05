#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

source "$CONFIG_DIR/colors.sh" # Loads all defined colors

# Handle mouse clicks for space switching
if [ "$SENDER" = "mouse.clicked" ]; then
  # Extract space number from the item name (e.g., space.1 -> 1)
  SPACE_NUMBER=$(echo "$NAME" | awk -F'.' '{print $2}')
  
  # Switch to the clicked space using keyboard shortcuts (works without yabai)
  # Map space numbers to their corresponding Control+Number key codes
  case $SPACE_NUMBER in
    1) osascript -e 'tell application "System Events" to key code 18 using control down' ;;
    2) osascript -e 'tell application "System Events" to key code 19 using control down' ;;
    3) osascript -e 'tell application "System Events" to key code 20 using control down' ;;
    4) osascript -e 'tell application "System Events" to key code 21 using control down' ;;
    5) osascript -e 'tell application "System Events" to key code 23 using control down' ;;
    6) osascript -e 'tell application "System Events" to key code 22 using control down' ;;
    7) osascript -e 'tell application "System Events" to key code 26 using control down' ;;
    8) osascript -e 'tell application "System Events" to key code 28 using control down' ;;
    9) osascript -e 'tell application "System Events" to key code 25 using control down' ;;
    10) osascript -e 'tell application "System Events" to key code 29 using control down' ;;
  esac
  exit 0
fi

# Handle space selection visual updates first (this runs on space changes)
if [ "$SENDER" != "mouse.entered" ] && [ "$SENDER" != "mouse.exited" ]; then
  if [ "$SELECTED" = "true" ]; then
    sketchybar --set $NAME background.drawing=on \
                           background.color=0xff7c7f93 \
                           label.color=$WHITE \
                           icon.color=$WHITE
  else
    sketchybar --set $NAME background.drawing=off \
                           label.color=$ACCENT_COLOR \
                           icon.color=$ACCENT_COLOR
  fi
fi

# Handle mouse hover effects (only for mouse events)
if [ "$SENDER" = "mouse.entered" ]; then
  # Show hover effect only if not already selected
  if [ "$SELECTED" != "true" ]; then
    sketchybar --set $NAME background.drawing=on \
                           background.color=0xaa585b70 \
                           label.color=$WHITE \
                           icon.color=$WHITE
  fi
fi

if [ "$SENDER" = "mouse.exited" ]; then
  # Remove hover effect only if not selected
  if [ "$SELECTED" != "true" ]; then
    sketchybar --set $NAME background.drawing=off \
                           label.color=$ACCENT_COLOR \
                           icon.color=$ACCENT_COLOR
  fi
fi
