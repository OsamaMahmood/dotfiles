#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Handle mouse clicks - switch workspace via aerospace
if [ "$SENDER" = "mouse.clicked" ]; then
  SPACE_NUMBER=$(echo "$NAME" | awk -F'.' '{print $2}')
  aerospace workspace "$SPACE_NUMBER"
  exit 0
fi

# Handle mouse hover effects
if [ "$SENDER" = "mouse.entered" ]; then
  SPACE_NUMBER=$(echo "$NAME" | awk -F'.' '{print $2}')
  FOCUSED=$(aerospace list-workspaces --focused)

  if [ "$SPACE_NUMBER" != "$FOCUSED" ]; then
    sketchybar --set $NAME background.drawing=on \
                           background.color=0xaa585b70 \
                           label.color=$WHITE \
                           icon.color=$WHITE
  fi
fi

if [ "$SENDER" = "mouse.exited" ]; then
  SPACE_NUMBER=$(echo "$NAME" | awk -F'.' '{print $2}')
  FOCUSED=$(aerospace list-workspaces --focused)

  if [ "$SPACE_NUMBER" != "$FOCUSED" ]; then
    sketchybar --set $NAME background.drawing=off \
                           label.color=$ACCENT_COLOR \
                           icon.color=$ACCENT_COLOR
  fi
fi
