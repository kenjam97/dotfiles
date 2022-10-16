#!/usr/bin/env sh

sketchybar --add item     calendar right               \
           --set calendar update_freq=15               \
                          icon=cal                     \
                          icon.color=0xffebdbb2        \
                          icon.font="$FONT:Bold:12.0"  \
                          icon.padding_left=15         \
                          label.width=55               \
                          label.align=right            \
                          label.color=0xffebdbb2       \
                          label.padding_right=15       \
                          align=center                 \
                          script="~/.config/sketchybar/plugins/time.sh" \
                          background.color=0xff3c3836  \
                          background.height=20         \
                          background.corner_radius=10
