#!/bin/bash

sketchybar --add item front_app left \
           --set front_app       background.drawing=on \
                                 background.color=0xff6c7086 \
                                 background.corner_radius=15 \
                                 background.height=28 \
                                 icon.color=$WHITE \
                                 icon.font="sketchybar-app-font:Regular:17.0" \
                                 label.color=$WHITE \
                                 label.font="SF Pro:Semibold:16.0" \
                                 label.padding_left=8 \
                                 label.padding_right=8 \
                                 icon.padding_left=8 \
                                 icon.padding_right=8 \
                                 script="$PLUGIN_DIR/front_app.sh"            \
           --subscribe front_app front_app_switched
