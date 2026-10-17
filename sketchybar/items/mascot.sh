# Claude critter (the Zebar mascot, in glyph form): bops while Spotify plays; click = play/pause.
sketchybar --add item mascot right \
           --set mascot icon=$ICON_CRITTER \
                        icon.font="$FONT:Bold:18.0" \
                        icon.color=$CLAUDE \
                        icon.padding_left=12 \
                        icon.padding_right=4 \
                        label.font="$FONT:Bold:11.0" \
                        label.color=$PINK \
                        label.padding_right=10 \
                        label.width=16 \
                        label="" \
                        background.color=$PILL_BG \
                        background.border_color=$PILL_BORDER \
                        background.border_width=1 \
                        background.corner_radius=12 \
                        background.height=34 \
                        updates=on \
                        script="$PLUGINS/mascot.sh" \
                        click_script="osascript -e 'tell application \"Spotify\" to playpause'" \
           --subscribe mascot media_state
gap gap.mascot right
