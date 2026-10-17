# Stats pill, left to right: volume (scroll to change), cpu, memory, network, battery.
# Right-side items are added right-to-left, hence the reverse order.
stat() {  # stat <name> <icon colour> [sketchybar --set args...]
  local name=$1 color=$2; shift 2
  sketchybar --add item stat.$name right \
             --set stat.$name icon.color=$color label.width=40 script="$PLUGINS/$name.sh" "$@"
}

stat battery $GREEN update_freq=60 label.padding_right=10
sketchybar --subscribe stat.battery power_source_change system_woke
stat network $TEAL update_freq=10 label.drawing=off icon.padding_right=6
sketchybar --subscribe stat.network wifi_change system_woke
stat memory $MAUVE update_freq=5
stat cpu $BLUE update_freq=3
stat volume $PEACH icon.padding_left=10
sketchybar --subscribe stat.volume volume_change mouse.scrolled

pill stats '/stat\..*/'
gap gap.stats right
