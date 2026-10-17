# Spotify pill: prev / play-pause / next + scrolling track. Driven by Spotify's own
# PlaybackStateChanged notification (works where macOS's MediaRemote is locked down).
# Hidden when nothing is playing or paused.
spotify() { echo "osascript -e 'tell application \"Spotify\" to $1'"; }

sketchybar --add event spotify_change com.spotify.client.PlaybackStateChanged \
           --add event media_state  # tells the mascot to dance

sketchybar --add item media.track right \
           --set media.track drawing=off \
                             icon=$ICON_MUSIC \
                             icon.color=$PINK \
                             label.max_chars=28 \
                             scroll_texts=on \
                             label.padding_right=12 \
                             updates=on \
                             script="$PLUGINS/media.sh" \
           --subscribe media.track spotify_change

sketchybar --add item media.next right \
           --set media.next drawing=off icon=$ICON_NEXT icon.padding_right=6 label.drawing=off \
                            click_script="$(spotify 'next track')" \
           --add item media.play right \
           --set media.play drawing=off icon=$ICON_PLAY icon.padding_left=2 icon.padding_right=2 label.drawing=off \
                            click_script="$(spotify playpause)" \
           --add item media.prev right \
           --set media.prev drawing=off icon=$ICON_PREV icon.padding_left=12 label.drawing=off \
                            click_script="$(spotify 'previous track')"

pill media '/media\..*/'
sketchybar --set media drawing=off
gap gap.media right
