#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map_fn.sh" > /dev/null 2>&1

# Get focused workspace
if [ -n "$FOCUSED_WORKSPACE" ]; then
  FOCUSED="$FOCUSED_WORKSPACE"
else
  FOCUSED=$(aerospace list-workspaces --focused)
fi

# Initialize icon strips for workspaces 1-9
ICONS_1=" " ICONS_2=" " ICONS_3=" " ICONS_4=" " ICONS_5=" "
ICONS_6=" " ICONS_7=" " ICONS_8=" " ICONS_9=" "

# Single aerospace query for ALL windows
while IFS='|' read -r app ws; do
  [ -z "$app" ] && continue
  case "$ws" in
    [1-9]) ;;
    *) continue ;;
  esac
  icon_map "$app"
  eval "ICONS_${ws}+=' $icon_result'"
done <<< "$(aerospace list-windows --all --format '%{app-name}|%{workspace}' 2>/dev/null)"

# Update highlighting first (instant visual feedback)
HIGHLIGHT_ARGS=()
for sid in 1 2 3 4 5 6 7 8 9; do
  if [ "$sid" = "$FOCUSED" ]; then
    HIGHLIGHT_ARGS+=(--set space.$sid background.drawing=on
                                      background.color=0xff7c7f93
                                      label.color=$WHITE
                                      icon.color=$WHITE)
  else
    HIGHLIGHT_ARGS+=(--set space.$sid background.drawing=off
                                      label.color=$ACCENT_COLOR
                                      icon.color=$ACCENT_COLOR)
  fi
done
sketchybar "${HIGHLIGHT_ARGS[@]}"

# Then update window icon labels
LABEL_ARGS=()
for sid in 1 2 3 4 5 6 7 8 9; do
  eval "icon_strip=\"\${ICONS_${sid}}\""
  if [ "$icon_strip" = " " ]; then
    icon_strip=" —"
  fi
  LABEL_ARGS+=(--set space.$sid label="$icon_strip")
done
sketchybar "${LABEL_ARGS[@]}"
