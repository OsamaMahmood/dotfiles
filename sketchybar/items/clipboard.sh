#!/bin/bash

sketchybar --add item clipboard right \
           --set clipboard icon="􀉂" \
                          background.drawing=on \
                          click_script="$PLUGIN_DIR/clipboard.sh"
