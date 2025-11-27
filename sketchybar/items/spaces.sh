#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

# SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")
# SPACE_ICONS=("I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X")
# typically I arrange spaces as:
# space icons 1 is code editor, 2, is browser, 3 is slack, 4 is spotify and 5+ are just whatever else I might have open
# add youtube play icon
SPACE_ICONS=("" "" "" "" "4" "5" "6" "7" "8" "9" "10")

for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  sketchybar --add space      space.$sid left                    \
             --set space.$sid associated_space=$sid              \
                              icon=${SPACE_ICONS[i]}             \
                              icon.font.size=20                       \
                              icon.padding_left=22               \
                              icon.padding_right=22              \
                              icon.color=$EVERFOREST_BG_YELLOW   \
                              icon.highlight_color=$EVERFOREST_HIGHLIGHT        \
                              background.padding_left=-8         \
                              background.padding_right=-8        \
                              background.height=20               \
                              background.corner_radius=10        \
                              background.color=$EVERFOREST_BASE            \
                              background.drawing=on              \
                              label.drawing=off                  \
                              click_script="$SPACE_CLICK_SCRIPT"
done

# sketchybar   --add item       separator left                          \
#              --set separator  icon=                                  \
#                               icon.font="Hack Nerd Font:Regular:16.0" \
#                               background.padding_left=26              \
#                               background.padding_right=15             \
#                               label.drawing=off                       \
#                               icon.color=$WHITE
