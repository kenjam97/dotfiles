# Workspace buttons 1-10. plugins/spaces.sh shows the ones yabai has and styles them like
# Zebar: focused = mauve, visible on another display = surface0, occupied vs empty by text colour.
for sid in {1..10}; do
  sketchybar --add item space.$sid left \
             --set space.$sid drawing=off \
                              icon.drawing=off \
                              label=$sid \
                              label.align=center \
                              label.width=26 \
                              label.padding_left=0 \
                              label.padding_right=0 \
                              background.height=24 \
                              background.corner_radius=8 \
                              background.color=$TRANSPARENT \
                              padding_left=2 \
                              padding_right=2 \
                              click_script="yabai -m space --focus $sid"
done
sketchybar --set space.1 padding_left=5  # right edge padding goes on the last visible space (plugin)

sketchybar --add event window_focus \
           --add item spaces_refresh left \
           --set spaces_refresh drawing=off updates=on script="$PLUGINS/spaces.sh" \
           --subscribe spaces_refresh space_change space_windows_change display_change front_app_switched window_focus

pill workspaces '/space\..*/'  # sketchybar's patterns don't support [0-9]+
gap gap.spaces left
