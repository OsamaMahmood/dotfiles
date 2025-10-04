#!/bin/bash

sketchybar --add item volume right \
           --set volume                         background.drawing=on \
                        script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change mouse.scrolled 
