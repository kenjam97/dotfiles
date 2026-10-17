#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

sketchybar --add item     calendar right               \
           --set calendar update_freq=15               \
                          icon=cal                     \
                          icon.color=$TEXT             \
                          icon.font="$FONT:Bold:12.0"  \
                          icon.padding_left=15         \
                          label.width=55               \
                          label.align=right            \
                          label.color=$TEXT            \
                          label.padding_right=15       \
                          align=center                 \
                          script="~/.config/sketchybar/plugins/time.sh" \
                          background.color=$BASE      \
                          background.height=20         \
                          background.corner_radius=10
