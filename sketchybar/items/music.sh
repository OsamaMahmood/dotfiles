#!/bin/bash

# Load music helper functions (with fallback path resolution)
HELPER_PATH="$PLUGIN_DIR/music_helpers.sh"
if [ -z "$PLUGIN_DIR" ]; then
  # Fallback: construct path relative to config directory
  SCRIPT_DIR="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")"
  HELPER_PATH="$(dirname "$SCRIPT_DIR")/plugins/music_helpers.sh"
fi
source "$HELPER_PATH" 2>/dev/null || {
  echo "Warning: Could not load music helpers from $HELPER_PATH" >&2
  exit 1
}

# Create music control buttons using helper functions
create_music_button "music-next" "􀊋" "curl -s --max-time 0.5 -X POST 0.0.0.0:26538/api/v1/next >/dev/null 2>&1 && $PLUGIN_DIR/youtube-music.sh skip-status-check"

# Main music display with standardized update frequency
sketchybar --add item music right \
           --set music icon="􁁒" \
                       label="Loading…" \
                       update_freq=3 \
                       label.padding_right=3 \
                       label.max_chars=15 \
                       scroll_texts=on \
                       background.drawing=on \
                       script="$PLUGIN_DIR/youtube-music.sh" \
                       click_script="$PLUGIN_DIR/youtube-music-click-handler.sh"

create_music_button "music-prev" "􀊉" "curl -s --max-time 0.5 -X POST 0.0.0.0:26538/api/v1/previous >/dev/null 2>&1 && $PLUGIN_DIR/youtube-music.sh skip-status-check"