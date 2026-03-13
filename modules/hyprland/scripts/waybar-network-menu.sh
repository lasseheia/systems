set -eu

choice=$(printf '%s\n' "Toggle Wi-Fi" "Open nmtui" "" | wofi --dmenu --prompt "Network" || true)
case "$choice" in
  "Toggle Wi-Fi")
    if [ "$(nmcli radio wifi)" = "enabled" ]; then
      nmcli radio wifi off
    else
      nmcli radio wifi on
    fi
    ;;
  "Open nmtui")
    alacritty -e nmtui
    ;;
esac
