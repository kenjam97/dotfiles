#!/usr/bin/env bash
# Claude Code status line, Catppuccin Mocha, two rows:
#   󰚩 Opus ▂▄▆█   dotfiles  main ●3   +156 −23   42m
#   ctx ▕████████▋···············▏ 41%  164k / 400k → compact    5h ▰▰▱▱▱ 34% 2h10m
# The bar fills toward the auto-compact point (modelSettings.autoCompactWindow)
# when one is set, since that's when the session actually gets summarised.
input=$(cat)
S=$'\x1f'
IFS=$S read -r model model_id effort dir pct size added removed dur five five_reset <<<"$(jq -r '[
  .model.display_name // "?", .model.id // "", .effort.level // "",
  .workspace.current_dir // .cwd // "", .context_window.used_percentage // 0,
  .context_window.context_window_size // 200000,
  .cost.total_lines_added // 0, .cost.total_lines_removed // 0, .cost.total_duration_ms // 0,
  .rate_limits.five_hour.used_percentage // "", .rate_limits.five_hour.resets_at // ""
] | map(tostring) | join("\u001f")' <<<"$input")"

compact=$(jq -r --arg m "$model_id" '.modelSettings[$m].autoCompactWindow // empty' ~/.claude/settings.json 2>/dev/null)

fg() { printf '\e[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
R=$'\e[0m' B=$'\e[1m'
text=cdd6f4 sub=a6adc8 dim=585b70 faint=45475a
mauve=cba6f7 blue=89b4fa sky=89dceb green=a6e3a1 yellow=f9e2af peach=fab387 red=f38ba8

# Colour at t (0..1000) along green → yellow → peach → red.
grad() {
  local t=$1 stops=($green $yellow $peach $red) seg a b i r g bl
  ((t < 0)) && t=0; ((t > 999)) && t=999
  seg=$((t * 3 / 1000)); i=$((t * 3 % 1000))
  a=${stops[seg]} b=${stops[seg + 1]}
  r=$((0x${a:0:2} + (0x${b:0:2} - 0x${a:0:2}) * i / 1000))
  g=$((0x${a:2:2} + (0x${b:2:2} - 0x${a:2:2}) * i / 1000))
  bl=$((0x${a:4:2} + (0x${b:4:2} - 0x${a:4:2}) * i / 1000))
  printf '\e[38;2;%d;%d;%dm' $r $g $bl
}

human() {
  local n=$1 t
  if ((n >= 1000000)); then
    t=$((n / 100000))
    if ((t % 10)); then printf '%d.%dM' $((t / 10)) $((t % 10)); else printf '%dM' $((t / 10)); fi
  else printf '%dk' $((n / 1000)); fi
}

# ── row 1 ──────────────────────────────────────────────
case $effort in
  low) lit=1 ;; medium) lit=2 ;; high) lit=3 ;; xhigh|max) lit=4 ;; *) lit=0 ;;
esac
bars=(▂ ▄ ▆ █) eff=""
if ((lit)); then
  ecol=$mauve; [ "$effort" = max ] && ecol=$red
  for i in 0 1 2 3; do
    if ((i < lit)); then eff+="$(fg $ecol)${bars[i]}"; else eff+="$(fg $faint)${bars[i]}"; fi
  done
  eff=" $eff"
fi
row1="$(fg $mauve)${B}󰚩 ${model}${R}${eff}${R}"

if [ -n "$dir" ]; then
  row1+="  $(fg $blue) ${dir##*/}${R}"
  branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    row1+="  $(fg $sky) ${branch}${R}"
    ((dirty)) && row1+=" $(fg $peach)●${dirty}${R}"
  fi
fi
((added || removed)) && row1+="  $(fg $green)+${added}${R} $(fg $red)−${removed}${R}"
mins=$((dur / 60000))
if ((mins >= 60)); then el="$((mins / 60))h$((mins % 60))m"; else el="${mins}m"; fi
row1+="  $(fg $dim) ${el}${R}"

# ── row 2: context meter ───────────────────────────────
pct=${pct%%.*}
used=$((pct * size / 100))
budget=$size label="of $(human $size)"
if [ -n "$compact" ] && ((compact < size)); then budget=$compact label="/ $(human $compact) → compact"; fi
W=28
eighths=$((used * W * 8 / budget)); ((eighths > W * 8)) && eighths=$((W * 8))
frac=$((used * 1000 / budget)); ((frac > 1000)) && frac=1000
part=(" " ▏ ▎ ▍ ▌ ▋ ▊ ▉)
bar=""
for ((c = 0; c < W; c++)); do
  fill=$((eighths - c * 8))
  if ((fill >= 8)); then bar+="$(grad $((c * 1000 / (W - 1))))█"
  elif ((fill > 0)); then bar+="$(grad $((c * 1000 / (W - 1))))${part[fill]}"
  else bar+="$(fg $faint)·"
  fi
done

now=$(grad "$frac")
row2="$(fg $dim)ctx ${R}$(fg $faint)▕${bar}$(fg $faint)▏${R} ${now}${B}$((frac / 10))%${R}"
row2+="  $(fg $sub)$(human $used) ${label}${R}"
((frac >= 800)) && row2+="  ${now}${B}󰀦 /compact or /clear${R}"

if [ -n "$five" ]; then
  f=${five%%.*}; seg=""
  for i in 1 2 3 4 5; do
    if ((f >= i * 20 - 10)); then seg+="$(grad $((f * 10)))▰"; else seg+="$(fg $faint)▱"; fi
  done
  row2+="    $(fg $dim)5h ${R}${seg} $(grad $((f * 10)))${f}%${R}"
  if [ -n "$five_reset" ]; then
    left=$(((${five_reset%%.*} - $(date +%s)) / 60))
    ((left > 0)) && row2+=" $(fg $dim)↻ $((left / 60))h$((left % 60))m${R}"
  fi
fi

printf '%s\n%s\n' "$row1" "$row2"
