#!/bin/bash

# SketchyBar Clipboard Manager Plugin  
# Opens Maccy directly to avoid keyboard simulation interference

# Provide immediate visual feedback
sketchybar --set "$NAME" icon.color=0xff89b4fa

# Open Maccy directly - this should show the clipboard interface
# without interfering with keyboard input
open -a "Twingate"

# Reset visual feedback
sleep 0.1
sketchybar --set "$NAME" icon.color=0xffffffff
