# Focused app (mauve) + window title (subtext0) in a pill, so it reads on any wallpaper.
sketchybar --add item front_app left \
           --set front_app icon.font="$FONT:Bold:13.0" \
                           icon.color=$MAUVE \
                           icon.padding_left=12 \
                           icon.padding_right=8 \
                           label.color=$SUBTEXT0 \
                           label.max_chars=60 \
                           label.padding_right=12 \
                           background.color=$PILL_BG \
                           background.border_color=$PILL_BORDER \
                           background.border_width=1 \
                           background.corner_radius=12 \
                           background.height=34 \
                           updates=on \
                           script="$PLUGINS/front_app.sh" \
           --subscribe front_app front_app_switched window_focus space_change
