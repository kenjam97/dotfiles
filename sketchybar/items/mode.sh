# Layout badge (Zebar's tiling-direction button): bsp / stack / float; click toggles bsp <-> float.
sketchybar --add item mode left \
           --set mode icon.color=$SUBTEXT0 \
                      icon.padding_left=10 \
                      icon.padding_right=10 \
                      label.drawing=off \
                      background.color=$PILL_BG \
                      background.border_color=$PILL_BORDER \
                      background.border_width=1 \
                      background.corner_radius=12 \
                      background.height=34 \
                      script="$PLUGINS/mode.sh" \
                      click_script="$PLUGINS/mode.sh toggle" \
           --subscribe mode space_change mouse.entered mouse.exited
gap gap.mode left
