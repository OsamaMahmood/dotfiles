#!/bin/bash

SPACE_SIDS=(1 2 3 4 5 6 7 8 9 10)

for sid in "${SPACE_SIDS[@]}"
do
  
  
  sketchybar --add space space.$sid left                                 \
             --set space.$sid space=$sid                                 \
                              icon=$sid                                  \
                              icon.padding_left=5           \
                              icon.padding_right=0                       \
                              label.font="sketchybar-app-font:Regular:17.0" \
                              label.padding_left=5                       \
                              label.padding_right=18                     \
                              label.y_offset=-1                          \
                              background.corner_radius=15                \
                              background.height=28                       \
                              background.border_width=0                  \
                              background.padding_left=0                  \
                              background.padding_right=0                 \
                              padding_left=3                \
                              padding_right=3                            \
                              script="$PLUGIN_DIR/space.sh"              \
             --subscribe space.$sid mouse.clicked mouse.entered mouse.exited
done

sketchybar --add item space_separator left                             \
           --set space_separator icon="􀆊"                                \
                                 icon.color=$ACCENT_COLOR \
                                 icon.padding_left=5                   \
                                 label.drawing=off                     \
                                 background.drawing=off                \
                                 script="$PLUGIN_DIR/space_windows.sh" \
           --subscribe space_separator space_windows_change                           
