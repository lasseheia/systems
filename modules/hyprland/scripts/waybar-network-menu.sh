# shellcheck shell=sh
set -eu

toggle_wifi() {
  if rfkill -n -o TYPE,SOFT | grep -q '^wlan unblocked$'; then
    rfkill block wlan
  else
    rfkill unblock wlan
  fi
}

if [ "${1:-}" = "toggle" ]; then
  toggle_wifi
  exit
fi

choice=$(printf '%s\n' "Toggle Wi-Fi" "Open iwd" "" | wofi --dmenu --prompt "Network" || true)
case "$choice" in
  "Toggle Wi-Fi")
    toggle_wifi
    ;;
  "Open iwd")
    alacritty -e iwctl
    ;;
esac
