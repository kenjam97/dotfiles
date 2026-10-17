#!/bin/zsh
sketchybar --set clock.date label="$(date '+%a %-d %b')" \
           --set clock.time label="$(date '+%H:%M')"
