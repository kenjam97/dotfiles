#!/bin/zsh
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

batt=$(pmset -g batt)
p=$(grep -Eo '[0-9]+%' <<<"$batt" | head -1 | tr -d %)
[[ -z $p ]] && { sketchybar --set "$NAME" drawing=off; exit 0; }

if grep -q 'AC Power' <<<"$batt"; then
  icon=$ICON_BAT_CHARGING; color=$GREEN
else
  step=$(( (p + 5) / 10 )); (( step < 1 )) && step=1
  (( step >= 10 )) && icon=$ICON_BAT_FULL || icon=${ICON_BAT[$step]}
  (( p <= 20 )) && color=$RED || color=$GREEN
fi
sketchybar --set "$NAME" drawing=on icon="$icon" icon.color=$color label="${p}%"
