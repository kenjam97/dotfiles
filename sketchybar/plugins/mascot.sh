#!/bin/zsh
# media_state (from media.sh) starts/stops the dance; routine ticks while playing are the frames.
img="$CONFIG_DIR/critter"
if [[ $SENDER == media_state ]]; then
  if [[ $PLAYING == 1 ]]; then
    sketchybar --set "$NAME" update_freq=1 icon.padding_right=2 label.drawing=on
  else
    sketchybar --set "$NAME" update_freq=0 icon.background.image="$img/idle.png" icon.y_offset=0 icon.padding_right=12 label="" label.drawing=off
    exit 0
  fi
elif [[ $SENDER != routine ]]; then
  exit 0
fi

if (( $(date +%s) % 2 )); then
  sketchybar --set "$NAME" icon.background.image="$img/dance1.png" icon.y_offset=2 label="♪" label.y_offset=5
else
  sketchybar --set "$NAME" icon.background.image="$img/dance2.png" icon.y_offset=0 label="♫" label.y_offset=-1
fi
