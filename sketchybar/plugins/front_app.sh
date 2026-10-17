#!/bin/zsh
win=$(yabai -m query --windows --window 2>/dev/null)
if [[ -z $win ]]; then
  sketchybar --set front_app icon="" label="" drawing=off
  exit 0
fi
app=$(jq -r .app <<<"$win")
title=$(jq -r .title <<<"$win")
[[ $title == "$app" ]] && title=""
sketchybar --set front_app drawing=on icon="$app" label="$title"
