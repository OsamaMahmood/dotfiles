#!/bin/bash

# Fast play/pause toggle - optimized for instant response
# Skips redundant checks and uses optimistic updates

# Get current state first for optimistic update
CURRENT_SONG_INFO=$(curl -s --max-time 0.3 0.0.0.0:26538/api/v1/song-info 2>/dev/null)

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
  curl -s --max-time 0.5 -X POST 0.0.0.0:26538/api/v1/toggle-play >/dev/null 2>&1 &
  
  # Quick verification after short delay (background) - skip status check
  (sleep 0.8 && "$CONFIG_DIR/plugins/youtube-music.sh" skip-status-check) &
else
  # Fallback to regular flow if can't get current state
  curl -s --max-time 0.5 -X POST 0.0.0.0:26538/api/v1/toggle-play >/dev/null 2>&1
  sketchybar --trigger music
fi
