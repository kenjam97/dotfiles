#!/usr/bin/env bash
# Claude Code hook: record this session's state for the sketchybar critter.
#   critter.sh working|attention|done|end   (hook JSON on stdin; only session_id is used)
# One file per session in ~/.cache/claude-critter, so several sessions don't overwrite
# each other; sketchybar's mascot plugin picks the most urgent. Prints nothing: stdout from
# a UserPromptSubmit hook would be added to Claude's context.
state=$1
sid=$(jq -r '.session_id // empty' 2>/dev/null) || exit 0
[[ -n $sid && -n $state ]] || exit 0

dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-critter"
mkdir -p "$dir"
if [[ $state == end ]]; then
  rm -f "$dir/$sid"
else
  printf '%s %s\n' "$state" "$(date +%s)" >"$dir/$sid"
fi

sb=$(command -v sketchybar || echo /opt/homebrew/bin/sketchybar)
[[ -x $sb ]] && "$sb" --trigger claude_state >/dev/null 2>&1
exit 0
