#!/usr/bin/env sh

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")
# SPACE_ICONS=("I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X")

for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  sketchybar --add space      space.$sid left                    \
             --set space.$sid associated_space=$sid              \
                              icon=${SPACE_ICONS[i]}             \
                              icon.padding_left=22               \
                              icon.padding_right=22              \
                              icon.highlight_color=0xfffabd2f    \
                              background.padding_left=-8         \
                              background.padding_right=-8        \
                              background.height=20               \
                              background.corner_radius=10        \
                              background.color=0xff3c3836        \
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
