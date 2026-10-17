#!/bin/zsh
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

cores=$(sysctl -n hw.ncpu)
u=$(ps -A -o %cpu= | awk -v c="$cores" '{ s += $1 } END { v = s / c; printf "%d", (v > 100 ? 100 : v) }')
(( u > 85 )) && color=$RED || color=$TEXT
sketchybar --set "$NAME" icon="$ICON_CPU" label="${u}%" label.color=$color
