#!/bin/bash

sketchybar --add item apple_logo left \
           --set apple_logo icon=􀣺 \
                            icon.font="SF Pro:Black:16.0" \
                            icon.color=$WHITE \
                            label.drawing=off \
                            padding_left=4 \
                            padding_right=8 \
                            icon.padding_left=4 \
                            icon.padding_right=4 \
                            background.corner_radius=12 \
                            background.height=22 \
                            background.color=$ITEM_BG_COLOR \
                            background.drawing=on \
                            click_script="$PLUGIN_DIR/apple_menu.sh"
