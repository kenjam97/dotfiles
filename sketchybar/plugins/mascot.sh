#!/bin/zsh
# Picks the critter's mood each event/tick. Claude sessions (state files written by
# claude/hooks/critter.sh) beat music: attention > done > working > dancing > idle.
img="$CONFIG_DIR/critter"
dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-critter"
mkdir -p "$dir"
now=$(date +%s)

# media.sh tells us whether Spotify is playing; remember it for the ticks in between.
[[ $SENDER == media_state ]] && print -r -- "${PLAYING:-0}" >"$dir/.music"

typeset -A rank=(working 1 done 2 attention 3)
mood=idle
for f in "$dir"/*(N.); do
  read -r st ts <"$f"
  age=$(( now - ${ts:-0} ))
  if (( age > 43200 )); then rm -f "$f"; continue; fi   # crashed/abandoned session
  [[ $st == done && age -gt 600 ]] && continue          # "done" fades after 10 min
  [[ $st == working && age -gt 1800 ]] && continue      # no hook for 30 min: probably gone
  (( ${rank[$st]:-0} > ${rank[$mood]:-0} )) && mood=$st
done
[[ $mood == idle && $(<"$dir/.music" 2>/dev/null) == 1 ]] && mood=dance

case $mood in
  attention) frames=(wave1 wave2); freq=1 ;;
  working)   frames=(think1 think2 think3); freq=1 ;;
  dance)     frames=(dance1 dance2); freq=1 ;;
  done)      frames=(done); freq=30 ;;   # tick slowly so it can fade
  *)         frames=(idle); freq=0 ;;
esac
frame=${frames[$(( now % ${#frames} + 1 ))]}
y=0; [[ $frame == (dance1|wave1) ]] && y=1
sketchybar --set "$NAME" update_freq=$freq icon.background.image="$img/$frame.png" icon.y_offset=$y
