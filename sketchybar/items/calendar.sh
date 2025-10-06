#!/bin/bash

sketchybar --add item calendar right \
           --set calendar icon=􀧞  \
                          update_freq=60 \
                          padding_left=4 \
                          padding_right=2 \
                          background.drawing=on \
                          script="$PLUGIN_DIR/calendar.sh" \
                          click_script="$PLUGIN_DIR/calendar.sh click"
