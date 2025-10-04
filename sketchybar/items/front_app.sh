#!/bin/bash

sketchybar --add item front_app left \
           --set front_app       background.drawing=on \
                                 background.color=0xff6c7086 \
                                 background.corner_radius=8 \
                                 background.height=20 \
                                 icon.color=$WHITE \
                                 icon.font="sketchybar-app-font:Regular:14.0" \
                                 label.color=$WHITE \
                                 label.font="SF Pro:Semibold:14.0" \
                                 label.padding_left=6 \
                                 label.padding_right=6 \
                                 icon.padding_left=6 \
                                 icon.padding_right=6 \
                                 script="$PLUGIN_DIR/front_app.sh"            \
           --subscribe front_app front_app_switched
