#!/bin/bash

sketchybar --add item twingate right \
           --set twingate icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "Twingate")" \
                          icon.font="sketchybar-app-font:Regular:16.0" \
                          icon.width=16 \
                          background.drawing=on \
                          click_script="$PLUGIN_DIR/twingate.sh"
