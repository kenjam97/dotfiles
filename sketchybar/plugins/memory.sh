#!/bin/zsh
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

free=$(memory_pressure -Q | awk -F': ' '/free percentage/ { sub("%", "", $2); print $2 }')
u=$(( 100 - ${free:-0} ))
(( u > 85 )) && color=$RED || color=$TEXT
sketchybar --set "$NAME" icon="$ICON_MEM" label="${u}%" label.color=$color
