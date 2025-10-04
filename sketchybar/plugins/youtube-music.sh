#!/bin/bash

# YouTube Music display with optimized performance
# Usage: youtube-music.sh [skip-status-check]

# Load helper functions (with fallback path resolution)
HELPER_PATH="$PLUGIN_DIR/music_helpers.sh"
if [ -z "$PLUGIN_DIR" ]; then
  HELPER_PATH="$(dirname "$0")/music_helpers.sh"
fi
source "$HELPER_PATH" 2>/dev/null || {
  echo "Warning: Could not load music helpers" >&2
}

SKIP_STATUS_CHECK="$1"

# Check if ytmd API is available (reduced timeout for faster response)
# Skip this check if we just performed a successful action
YTMD_RUNNING=false
if [ "$SKIP_STATUS_CHECK" = "skip-status-check" ]; then
  YTMD_RUNNING=true  # Assume running since we just used it
elif curl -s --max-time 0.5 0.0.0.0:26538/api/v1/song-info >/dev/null 2>&1; then
  YTMD_RUNNING=true
fi


# Show/hide control buttons based on YouTube Music status  
if [ "$YTMD_RUNNING" = true ]; then
  # Show control buttons when YouTube Music is running
  toggle_music_controls "on"
else
  # Hide control buttons and show offline message
  toggle_music_controls "off"
  sketchybar --set music label="YouTube Music not running" icon="􀑪" drawing=on
  exit 0
fi

# Get song info from ytmd API for display update (reduced timeout)
SONG_INFO=$(curl -s --max-time 1 0.0.0.0:26538/api/v1/song-info)

# Check if we got valid JSON response
if [ -z "$SONG_INFO" ] || ! echo "$SONG_INFO" | jq empty 2>/dev/null; then
  sketchybar --set music label="No song playing" icon="􀑪" drawing=on
  exit 0
fi

# Extract song information
PAUSED="$(echo "$SONG_INFO" | jq -r '.isPaused // false')"
TITLE="$(echo "$SONG_INFO" | jq -r '.title // "Unknown"')"
ARTIST="$(echo "$SONG_INFO" | jq -r '.artist // "Unknown"')"

# Format song display (truncate if too long)
if [ "$TITLE" = "Unknown" ] && [ "$ARTIST" = "Unknown" ]; then
  CURRENT_SONG="No song playing"
  ICON="􀑪"
elif [ "$ARTIST" = "Unknown" ]; then
  CURRENT_SONG="$TITLE"
else
  CURRENT_SONG="$TITLE - $ARTIST"
fi

# Set play/pause icon only (separate buttons handle prev/next)
if [ "$PAUSED" = "true" ]; then
  ICON="􀊄"  # Play icon
else
  ICON="􀊆"  # Pause icon
fi

# Update display with current song info

# Update SketchyBar with song info (always target main music item)
if ! sketchybar --set music label="$CURRENT_SONG" icon="$ICON" drawing=on 2>/dev/null; then
  echo "Warning: Failed to update music display" >&2
fi