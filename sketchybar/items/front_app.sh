# Focused app (mauve) + window title (subtext0), no pill, like Zebar's window title.
sketchybar --add item front_app left \
           --set front_app icon.font="$FONT:Bold:13.0" \
                           icon.color=$MAUVE \
                           icon.padding_left=4 \
                           icon.padding_right=8 \
                           label.color=$SUBTEXT0 \
                           label.max_chars=60 \
                           updates=on \
                           script="$PLUGINS/front_app.sh" \
           --subscribe front_app front_app_switched window_focus space_change
