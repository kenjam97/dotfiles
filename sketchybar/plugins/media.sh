#!/bin/zsh
source "$CONFIG_DIR/icons.sh"

if [[ $SENDER == spotify_change ]]; then
  st=$(jq -r '."Player State" // empty' <<<"$INFO")
  song=$(jq -r '.Name // empty' <<<"$INFO")
  artist=$(jq -r '.Artist // empty' <<<"$INFO")
elif pgrep -xq Spotify; then  # startup: ask Spotify, but never launch it
  IFS=$'\t' read -r st song artist < <(osascript -e 'tell application "Spotify" to (player state as string) & tab & (name of current track) & tab & (artist of current track)' 2>/dev/null)
  st=${(C)st}
fi

items=(media media.prev media.play media.next media.track gap.media)
if [[ $st != Playing && $st != Paused ]] || [[ -z $song ]]; then
  args=(); for i in $items; do args+=(--set $i drawing=off); done
  sketchybar "${args[@]}" --trigger media_state PLAYING=0
  exit 0
fi

[[ $st == Playing ]] && play=$ICON_PAUSE || play=$ICON_PLAY
label=$song; [[ -n $artist ]] && label="$song · $artist"
args=(); for i in $items; do args+=(--set $i drawing=on); done
sketchybar "${args[@]}" \
           --set media.play icon="$play" \
           --set media.track label="$label" \
           --trigger media_state PLAYING=$([[ $st == Playing ]] && echo 1 || echo 0)
