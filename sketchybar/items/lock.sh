#!/bin/bash

sketchybar --add item lock right \
           --set lock icon=􀎠 \
                      icon.width=16 \
                      icon.color=0xfff38ba8 \
                      background.drawing=on \
                      script="$PLUGIN_DIR/lock.sh" \
           --subscribe lock mouse.clicked mouse.entered mouse.exited
