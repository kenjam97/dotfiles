#!/bin/zsh
source "$CONFIG_DIR/icons.sh"

if [[ $SENDER == mouse.scrolled ]]; then
  cur=$(osascript -e 'output volume of (get volume settings)')
  (( SCROLL_DELTA > 0 )) && step=2 || step=-2
  osascript -e "set volume output volume $(( cur + step ))"
  exit 0  # volume_change fires next and redraws
fi

if [[ $SENDER == volume_change ]]; then
  v=$INFO
else
  v=$(osascript -e 'output volume of (get volume settings)')
fi
muted=$(osascript -e 'output muted of (get volume settings)')

if [[ $muted == true ]] || (( v == 0 )); then icon=$ICON_VOL_OFF
elif (( v < 35 )); then icon=$ICON_VOL_LOW
elif (( v < 70 )); then icon=$ICON_VOL_MED
else icon=$ICON_VOL_HIGH
fi
sketchybar --set "$NAME" icon="$icon" label="${v}%"
