#!/usr/bin/env bash
# UserPromptSubmit hook: warn when a session has run 8+ hours or its transcript is 5MB+.
# Long sessions resend an ever-growing context every turn, and resuming after the
# prompt cache expires re-writes the whole thing. Nags at most once every 30 minutes per session.
payload=$(cat)
path=$(jq -r '.transcript_path // empty' <<<"$payload" 2>/dev/null) || exit 0
sid=$(jq -r '.session_id // "unknown"' <<<"$payload" 2>/dev/null)
[[ -n $path && -f $path ]] || exit 0

# GNU (Linux/WSL) and BSD (macOS) stat/date differ.
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1"; }
iso_epoch() { date -d "$1" +%s 2>/dev/null || date -j -u -f '%Y-%m-%dT%H:%M:%S' "${1%%.*}" +%s 2>/dev/null; }

size_mb=$(awk -v b="$(wc -c <"$path")" 'BEGIN { printf "%.1f", b / 1048576 }')
start=$(head -n 10 "$path" | grep -o '"timestamp":"[^"]*"' | head -1 | cut -d'"' -f4)
start_epoch=$( [[ -n $start ]] && iso_epoch "$start" || mtime "$path")
hours=$(awk -v s="$start_epoch" -v n="$(date +%s)" 'BEGIN { printf "%.1f", (n - s) / 3600 }')

awk -v h="$hours" -v m="$size_mb" 'BEGIN { exit !(h >= 8 || m >= 5) }' || exit 0

marker="${TMPDIR:-/tmp}/claude-long-session-$sid.txt"
if [[ -f $marker ]] && (( $(date +%s) - $(mtime "$marker") < 1800 )); then exit 0; fi
: >"$marker"

msg="Long session: ${hours}h old, transcript ${size_mb}MB. Every prompt resends this whole context. Run /clear (or start a new session) for the next task; /compact if you must keep context."
jq -cn --arg m "$msg" '{systemMessage: $m}'
exit 0
