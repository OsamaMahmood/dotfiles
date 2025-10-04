#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

# Helper function to get volume icon (eliminates duplication)
get_volume_icon() {
  local volume=$1
  case $volume in
    [6-9][0-9]|100) echo "􀊩" ;;
    [3-5][0-9]) echo "􀊥" ;;
    [1-9]|[1-2][0-9]) echo "􀊡" ;;
    *) echo "􀊣" ;;
  esac
}

if [ "$SENDER" = "volume_change" ]; then
  VOLUME=$INFO
  ICON=$(get_volume_icon $VOLUME)
  sketchybar --set $NAME icon="$ICON" label="$VOLUME%"
fi

# Handle mouse scroll events for volume control
if [ "$SENDER" = "mouse.scrolled" ]; then
  # Get current volume
  CURRENT_VOLUME=$(osascript -e "output volume of (get volume settings)")
  
  # Adjust volume based on scroll direction
  if [ "$SCROLL_DELTA" -gt 0 ]; then
    # Scroll up - increase volume
    NEW_VOLUME=$((CURRENT_VOLUME + 5))
    if [ $NEW_VOLUME -gt 100 ]; then
      NEW_VOLUME=100
    fi
  else
    # Scroll down - decrease volume
    NEW_VOLUME=$((CURRENT_VOLUME - 5))
    if [ $NEW_VOLUME -lt 0 ]; then
      NEW_VOLUME=0
    fi
  fi
  
  # Set new volume and update display
  osascript -e "set volume output volume $NEW_VOLUME"
  ICON=$(get_volume_icon $NEW_VOLUME)
  sketchybar --set $NAME icon="$ICON" label="$NEW_VOLUME%"
fi
