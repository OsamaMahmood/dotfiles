#!/bin/sh
# macOS memory percent for SketchyBar: (App Memory + Wired + Compressed) / Total

# Get page size and total RAM in one sysctl call
eval "$(sysctl -n vm.pagesize hw.memsize | awk 'NR==1{print "PAGE_SIZE="$1} NR==2{print "TOTAL_BYTES="$1}')"

# Parse vm_stat output efficiently in one pass
eval "$(vm_stat | awk '
/^Pages active:/ { print "ACTIVE=" $3 }
/^Pages speculative:/ { print "SPECULATIVE=" $3 }
/^Pages wired down:/ { print "WIRED=" $4 }
/^Pages occupied by compressor:/ { print "COMPRESSED=" $5 }
' | tr -d '.')"

# Calculate used memory (App Memory + Wired + Compressed)
USED_PAGES=$((ACTIVE + SPECULATIVE + WIRED + COMPRESSED))
USED_BYTES=$((USED_PAGES * PAGE_SIZE))
PERCENTAGE=$((USED_BYTES * 100 / TOTAL_BYTES))

# Error handling for invalid percentage
if [ -z "$PERCENTAGE" ] || ! [[ "$PERCENTAGE" =~ ^[0-9]+$ ]]; then
  PERCENTAGE="N/A"
fi

# Update SketchyBar with error handling
sketchybar --set "$NAME" label="${PERCENTAGE}%" 2>/dev/null || {
  echo "Error updating memory display" >&2
  exit 1
}