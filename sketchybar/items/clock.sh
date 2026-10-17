# Centre pill: blue calendar + date, mauve clock + time.
sketchybar --add item clock.date center \
           --set clock.date icon=$ICON_CALENDAR \
                            icon.color=$BLUE \
                            icon.padding_left=12 \
                            label.padding_right=10 \
                            update_freq=30 \
                            script="$PLUGINS/clock.sh" \
           --subscribe clock.date system_woke \
           --add item clock.time center \
           --set clock.time icon=$ICON_CLOCK \
                            icon.color=$MAUVE \
                            label.padding_right=12 \
                            background.drawing=off

pill clock '/clock\..*/'
