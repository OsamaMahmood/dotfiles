#!/bin/bash

sketchybar --add item cpu right \
           --set cpu  update_freq=5 \
                      icon=􀧓  \
                      background.drawing=on \
                      script="$PLUGIN_DIR/cpu.sh" 
