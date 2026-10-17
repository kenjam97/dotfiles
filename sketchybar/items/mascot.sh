# Claude critter: the Zebar mascot's pixel art (critter/make.py renders the frames).
# Shows Claude Code's state (claude_state, from claude/hooks/critter.sh), else bops while
# Spotify plays (media_state). Click = play/pause.
# icon.width is the whole pill (46pt, like Zebar). The frames are pill-sized with the critter
# centred in them, since sketchybar left-aligns icon images. Images render at px * scale pt:
# 120px * 0.383 = 46pt.
sketchybar --add event claude_state \
           --add item mascot right \
           --set mascot icon="" \
                        icon.width=46 \
                        icon.padding_left=0 \
                        icon.padding_right=0 \
                        icon.background.drawing=on \
                        icon.background.color=$TRANSPARENT \
                        icon.background.image="$CONFIG_DIR/critter/idle.png" \
                        icon.background.image.scale=0.383 \
                        label.drawing=off \
                        background.color=$PILL_BG \
                        background.border_color=$PILL_BORDER \
                        background.border_width=1 \
                        background.corner_radius=12 \
                        background.height=34 \
                        updates=on \
                        script="$PLUGINS/mascot.sh" \
                        click_script="osascript -e 'tell application \"Spotify\" to playpause'" \
           --subscribe mascot media_state claude_state
gap gap.mascot right
