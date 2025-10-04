#!/bin/bash

# Music control helper functions to reduce configuration redundancy

# Common styling for music control buttons
apply_music_button_style() {
  local item_name="$1"
  
  sketchybar --set "$item_name" \
             padding_left=2 \
             padding_right=2 \
             icon.padding_left=2 \
             icon.padding_right=2 \
             label.padding_left=1 \
             label.padding_right=1 \
             background.drawing=off \
             drawing=off
}

# Create a music control button with consistent styling
create_music_button() {
  local item_name="$1"
  local icon="$2" 
  local click_script="$3"
  local position="${4:-right}"
  
  sketchybar --add item "$item_name" "$position"
  apply_music_button_style "$item_name"
  
  sketchybar --set "$item_name" \
             icon="$icon" \
             click_script="$click_script"
}

# Toggle music control buttons visibility
toggle_music_controls() {
  local show="$1" # "on" or "off"
  local bg_drawing="$1" # "on" or "off"
  
  # Validate input
  if [ "$show" != "on" ] && [ "$show" != "off" ]; then
    echo "Error: Invalid visibility state '$show'" >&2
    return 1
  fi
  
  # Update controls with error handling
  if ! sketchybar --set music-prev drawing="$show" background.drawing="$bg_drawing" 2>/dev/null; then
    echo "Warning: Failed to update music-prev visibility" >&2
  fi
  
  if ! sketchybar --set music-next drawing="$show" background.drawing="$bg_drawing" 2>/dev/null; then
    echo "Warning: Failed to update music-next visibility" >&2
  fi
}
