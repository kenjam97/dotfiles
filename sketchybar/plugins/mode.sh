#!/bin/zsh
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

case "$SENDER" in
  mouse.entered) sketchybar --set mode icon.color=$TEXT; exit 0 ;;
  mouse.exited)  sketchybar --set mode icon.color=$SUBTEXT0; exit 0 ;;
esac

layout=$(yabai -m query --spaces --space 2>/dev/null | jq -r .type) || exit 0
if [[ $1 == toggle ]]; then
  [[ $layout == bsp ]] && layout=float || layout=bsp
  yabai -m space --layout $layout
fi

case $layout in
  bsp)   icon=$ICON_BSP ;;
  stack) icon=$ICON_STACK ;;
  *)     icon=$ICON_FLOAT ;;
esac
sketchybar --set mode icon="$icon"
