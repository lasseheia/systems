set -eu

choice=$(printf '%s\n' "Mute / Unmute" "Volume +5%" "Volume -5%" "Open Mixer" "" | wofi --dmenu --prompt "Audio" || true)
case "$choice" in
  "Mute / Unmute")
    pamixer -t
    ;;
  "Volume +5%")
    pamixer -i 5
    ;;
  "Volume -5%")
    pamixer -d 5
    ;;
  "Open Mixer")
    pwvucontrol
    ;;
esac
