#!/bin/zsh
# Icon only: macOS 14+ hides the SSID from scripts without location permission.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

iface=$(route -n get default 2>/dev/null | awk '/interface:/ { print $2 }')
wifi=$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }')

if [[ -z $iface ]]; then sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" icon.color=$RED
elif [[ $iface == "$wifi" ]]; then sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color=$TEAL
else sketchybar --set "$NAME" icon="$ICON_ETHERNET" icon.color=$TEAL
fi
