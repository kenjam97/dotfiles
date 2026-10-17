# Claude critter: the Zebar mascot's 16x12 pixel art (critter/make.py renders the frames).
# Bops while Spotify plays; click = play/pause.
sketchybar --add item mascot right \
           --set mascot icon="" \
                        icon.width=32 \
                        icon.padding_left=12 \
                        icon.padding_right=12 \
                        icon.background.drawing=on \
                        icon.background.color=$TRANSPARENT \
                        icon.background.image="$CONFIG_DIR/critter/idle.png" \
                        icon.background.image.scale=0.5 \
                        label.font="$FONT:Bold:11.0" \
                        label.color=$PINK \
                        label.padding_right=8 \
                        label.width=14 \
                        label.drawing=off \
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
