#!/bin/bash

sketchybar --add item memory right \
           --set memory update_freq=5 \
                        icon=􀫦  \
                        padding_right=4 \
                        background.drawing=on \
                        script="$PLUGIN_DIR/memory.sh"
