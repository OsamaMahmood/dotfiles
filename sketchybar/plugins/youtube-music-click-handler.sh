#!/bin/bash

# Smart music click handler - context-aware action based on current state
# - If YouTube Music not running → Launch the app
# - If YouTube Music running → Play/Pause toggle

# Check current YouTube Music status
if curl -s --max-time 0.5 0.0.0.0:26538/api/v1/song-info >/dev/null 2>&1; then
  # YouTube Music is running - use fast play/pause toggle
  "$CONFIG_DIR/plugins/youtube-music-fast-toggle.sh"
else
  # YouTube Music not running - launch the app
  echo "Launching YouTube Music..."
  
  # Update display immediately to show launching state
  sketchybar --set music label="Launching YouTube Music..." icon="􀑪"
  
  # Try multiple possible YouTube Music app names
  LAUNCHED=false
  
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
    # Wait for app to fully launch and API to become available
    echo "Waiting for YouTube Music to start..."
    
    # Check every second for up to 10 seconds
    for i in {1..10}; do
      sleep 1
      if curl -s --max-time 0.5 0.0.0.0:26538/api/v1/song-info >/dev/null 2>&1; then
        echo "YouTube Music launched successfully!"
        sketchybar --trigger music
        exit 0
      fi
      
      # Update progress indicator
      sketchybar --set music label="Starting YouTube Music...$i"
    done
    
    # If still not available after 10 seconds
    sketchybar --set music label="YouTube Music launch timeout" icon="􀑪"
    (sleep 3 && sketchybar --trigger music) &
  else
    # App not found
    echo "YouTube Music app not found in Applications folder"
    sketchybar --set music label="YouTube Music app not found" icon="􀑪"
    (sleep 3 && sketchybar --trigger music) &
  fi
fi
