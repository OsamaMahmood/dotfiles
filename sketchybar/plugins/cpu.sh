#!/bin/bash

# Single-pass CPU usage calculation for better performance
CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CURRENT_USER=$(whoami)

# Process CPU data in single pass - calculate both user and system CPU usage
CPU_PERCENT=$(ps -eo pcpu,user | awk -v user="$CURRENT_USER" -v cores="$CORE_COUNT" '
  NR > 1 { # Skip header
    if ($2 == user) {
      user_cpu += $1
    } else {
      sys_cpu += $1
    }
  }
  END {
    total_percent = (user_cpu + sys_cpu) / cores
    printf "%.0f", total_percent
  }
')

# Handle edge cases and errors
if [ -z "$CPU_PERCENT" ]; then
  CPU_PERCENT="0"
elif ! [[ "$CPU_PERCENT" =~ ^[0-9]+$ ]]; then
  CPU_PERCENT="N/A"
fi

sketchybar --set "$NAME" label="${CPU_PERCENT}%" 2>/dev/null || {
  echo "Error updating CPU display" >&2
  exit 1
}
