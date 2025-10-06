#!/bin/bash

# Unified YouTube Music script - handles all music-related functions
# Usage: youtube-music.sh [action] [options]
# Actions: display, toggle, click, next, previous

# Load helper functions (with fallback path resolution)
HELPER_PATH="$PLUGIN_DIR/music_helpers.sh"
if [ -z "$PLUGIN_DIR" ]; then
  HELPER_PATH="$(dirname "$0")/music_helpers.sh"
fi
source "$HELPER_PATH" 2>/dev/null || {
  echo "Warning: Could not load music helpers" >&2
}

ACTION="${1:-display}"
SKIP_STATUS_CHECK="$2"

# Common function to check if ytmd is running
check_ytmd_status() {
  local timeout="${1:-0.5}"
  curl -s --max-time "$timeout" 0.0.0.0:26538/api/v1/song-info >/dev/null 2>&1
}

# Function to get current song info
get_song_info() {
  local timeout="${1:-1}"
  curl -s --max-time "$timeout" 0.0.0.0:26538/api/v1/song-info 2>/dev/null
}

# Function to send API command
send_api_command() {
  local endpoint="$1"
  local timeout="${2:-0.5}"
  curl -s --max-time "$timeout" -X POST "0.0.0.0:26538/api/v1/$endpoint" >/dev/null 2>&1
}

# Function to launch YouTube Music app
launch_youtube_music() {
  echo "Launching YouTube Music..."
  sketchybar --set music label="Launching YouTube Music..." icon="􀑪"
  
  LAUNCHED=false
  
  # Try multiple possible YouTube Music app names
  if [ -d "/Applications/YouTube Music.app" ]; then
    open -a "YouTube Music" && LAUNCHED=true
  elif [ -d "/Applications/YouTube Music Desktop App.app" ]; then
    open -a "YouTube Music Desktop App" && LAUNCHED=true
  elif [ -d "/Applications/ytmd.app" ]; then
    open -a "ytmd" && LAUNCHED=true
  else
    # Search for any YouTube Music app in Applications
    YTMD_APP=$(find /Applications -name "*YouTube Music*.app" -o -name "*ytmd*.app" 2>/dev/null | head -1)
    if [ -n "$YTMD_APP" ]; then
      open "$YTMD_APP" && LAUNCHED=true
    fi
  fi
  
  if [ "$LAUNCHED" = true ]; then
    echo "Waiting for YouTube Music to start..."
    
    # Check every second for up to 10 seconds
    for i in {1..10}; do
      sleep 1
      if check_ytmd_status; then
        echo "YouTube Music launched successfully!"
        "$0" display
        exit 0
      fi
      sketchybar --set music label="Starting YouTube Music...$i"
    done
    
    # Timeout
    sketchybar --set music label="YouTube Music launch timeout" icon="􀑪"
    (sleep 3 && "$0" display) &
  else
    echo "YouTube Music app not found in Applications folder"
    sketchybar --set music label="YouTube Music app not found" icon="􀑪"
    (sleep 3 && "$0" display) &
  fi
}

# Function to update display
update_display() {
  local skip_check="$1"
  
  # Check if ytmd API is available
  YTMD_RUNNING=false
  if [ "$skip_check" = "skip-status-check" ]; then
    YTMD_RUNNING=true  # Assume running since we just used it
  elif check_ytmd_status; then
    YTMD_RUNNING=true
  fi

  # Show/hide control buttons based on YouTube Music status  
  if [ "$YTMD_RUNNING" = true ]; then
    toggle_music_controls "on"
  else
    toggle_music_controls "off"
    sketchybar --set music label="YouTube Music not running" icon="􀑪" drawing=on
    exit 0
  fi

  # Get song info from ytmd API for display update
  SONG_INFO=$(get_song_info 1)

  # Check if we got valid JSON response
  if [ -z "$SONG_INFO" ] || ! echo "$SONG_INFO" | jq empty 2>/dev/null; then
    sketchybar --set music label="No song playing" icon="􀑪" drawing=on
    exit 0
  fi

  # Extract song information
  PAUSED="$(echo "$SONG_INFO" | jq -r '.isPaused // false')"
  TITLE="$(echo "$SONG_INFO" | jq -r '.title // "Unknown"')"
  ARTIST="$(echo "$SONG_INFO" | jq -r '.artist // "Unknown"')"

  # Format song display
  if [ "$TITLE" = "Unknown" ] && [ "$ARTIST" = "Unknown" ]; then
    CURRENT_SONG="No song playing"
    ICON="􀑪"
  elif [ "$ARTIST" = "Unknown" ]; then
    CURRENT_SONG="$TITLE"
  else
    CURRENT_SONG="$TITLE - $ARTIST"
  fi

  # Set play/pause icon
  if [ "$PAUSED" = "true" ]; then
    ICON="􀊄"  # Play icon
  else
    ICON="􀊆"  # Pause icon
  fi

  # Update SketchyBar with song info
  if ! sketchybar --set music label="$CURRENT_SONG" icon="$ICON" drawing=on 2>/dev/null; then
    echo "Warning: Failed to update music display" >&2
  fi
}

# Function for fast toggle with optimistic updates
fast_toggle() {
  # Get current state first for optimistic update
  CURRENT_SONG_INFO=$(get_song_info 0.3)

  if [ -n "$CURRENT_SONG_INFO" ] && echo "$CURRENT_SONG_INFO" | jq empty 2>/dev/null; then
    CURRENT_PAUSED="$(echo "$CURRENT_SONG_INFO" | jq -r '.isPaused // false')"
    
    # Optimistic icon update (predict the new state)
    if [ "$CURRENT_PAUSED" = "true" ]; then
      NEW_ICON="􀊆"  # Will become pause icon (currently playing)
    else
      NEW_ICON="􀊄"  # Will become play icon (currently paused)  
    fi
    
    # Update icon immediately (optimistic)
    sketchybar --set music icon="$NEW_ICON"
    
    # Execute toggle in background
    send_api_command "toggle-play" &
    
    # Quick verification after short delay (background)
    (sleep 0.8 && "$0" display skip-status-check) &
  else
    # Fallback to regular flow if can't get current state
    send_api_command "toggle-play"
    "$0" display
  fi
}

# Function for smart click handling
smart_click() {
  if check_ytmd_status; then
    # YouTube Music is running - use fast toggle
    fast_toggle
  else
    # YouTube Music not running - launch the app
    launch_youtube_music
  fi
}

# Main action dispatcher
case "$ACTION" in
  "display")
    update_display "$SKIP_STATUS_CHECK"
    ;;
  "toggle")
    fast_toggle
    ;;
  "click")
    smart_click
    ;;
  "next")
    send_api_command "next" && "$0" display skip-status-check
    ;;
  "previous")
    send_api_command "previous" && "$0" display skip-status-check
    ;;
  *)
    echo "Usage: $0 {display|toggle|click|next|previous} [skip-status-check]"
    echo "  display          - Update music display (default)"
    echo "  toggle           - Fast play/pause toggle"
    echo "  click            - Smart click handler (launch or toggle)"
    echo "  next             - Next track"
    echo "  previous         - Previous track"
    exit 1
    ;;
esac
