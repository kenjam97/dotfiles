# Focused app (mauve) + window title (subtext0), no pill, like Zebar's window title.
sketchybar --add item front_app left \
           --set front_app icon.font="$FONT:Bold:13.0" \
                           icon.color=$MAUVE \
                           icon.padding_left=4 \
                           icon.padding_right=8 \
                           label.color=$SUBTEXT0 \
                           label.max_chars=60 \
                           icon.shadow.drawing=on \
                           icon.shadow.color=0xa011111b \
                           icon.shadow.distance=2 \
                           label.shadow.drawing=on \
                           label.shadow.color=0xa011111b \
                           label.shadow.distance=2 \
                           updates=on \
                           script="$PLUGINS/front_app.sh" \
           --subscribe front_app front_app_switched window_focus space_change
