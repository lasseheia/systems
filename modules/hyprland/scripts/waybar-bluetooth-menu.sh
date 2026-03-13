set -eu

choice=$(printf '%s\n' "Toggle Bluetooth" "Open Overskride" "" | wofi --dmenu --prompt "Bluetooth" || true)
case "$choice" in
  "Toggle Bluetooth")
    if bluetoothctl show | grep -q "Powered: yes"; then
      bluetoothctl power off
    else
      bluetoothctl power on
    fi
    ;;
  "Open Overskride")
    overskride
    ;;
esac
