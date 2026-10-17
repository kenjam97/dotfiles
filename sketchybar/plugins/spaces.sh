#!/bin/zsh
source "$CONFIG_DIR/colors.sh"

spaces=$(yabai -m query --spaces 2>/dev/null) || exit 0
typeset -A state
while read -r idx focused visible wins; do
  if [[ $focused == true ]]; then state[$idx]="background.color=$MAUVE label.color=$CRUST"
  elif [[ $visible == true ]]; then state[$idx]="background.color=$SURFACE0 label.color=$LAVENDER"
  elif (( wins > 0 )); then state[$idx]="background.color=$TRANSPARENT label.color=$SUBTEXT0"
  else state[$idx]="background.color=$TRANSPARENT label.color=$OVERLAY1"
  fi
done < <(jq -r '.[] | "\(.index) \(."has-focus") \(."is-visible") \(.windows | length)"' <<<"$spaces")

last=${${(On)${(k)state}}[1]}
args=()
for sid in {1..10}; do
  if [[ -n ${state[$sid]} ]]; then
    args+=(--set space.$sid drawing=on ${=state[$sid]} padding_right=$(( sid == last ? 5 : 2 )))
  else args+=(--set space.$sid drawing=off)
  fi
done
sketchybar --animate tanh 8 "${args[@]}"
