#!/bin/zsh
# media_state (from media.sh) starts/stops the dance; routine ticks while playing are the frames.
if [[ $SENDER == media_state ]]; then
  if [[ $PLAYING == 1 ]]; then
    sketchybar --set "$NAME" update_freq=1
  else
    sketchybar --set "$NAME" update_freq=0 icon.y_offset=0 label=""
    exit 0
  fi
elif [[ $SENDER != routine ]]; then
  exit 0
fi

if (( $(date +%s) % 2 )); then
  sketchybar --animate sin 15 --set "$NAME" icon.y_offset=3 label="♪" label.y_offset=4
else
  sketchybar --animate sin 15 --set "$NAME" icon.y_offset=0 label="♫" label.y_offset=-1
fi
