set -eu

printf '%s\n' \
  "Launchers" \
  "  SUPER + Return   Alacritty" \
  "  SUPER + R        App launcher (Wofi)" \
  "  SUPER + V        Clipboard history" \
  "  SUPER + B        Bluetooth app (Overskride)" \
  "  SUPER + S        Audio mixer" \
  "" \
  "Windows" \
  "  SUPER + Q        Close focused window" \
  "  SUPER + F        Fullscreen" \
  "  SUPER + M        Exit Hyprland" \
  "" \
  "Focus" \
  "  SUPER + H/J/K/L  Move focus" \
  "" \
  "Resize" \
  "  SUPER + CTRL + H/J/K/L   Resize active window" \
  "" \
  "Move Window" \
  "  SUPER + SHIFT + H/J/K/L  Move active window" \
  "" \
  "Workspaces" \
  "  SUPER + 1..0     Switch to workspace 1..10" \
  "  SUPER + SHIFT + 1..0  Move window to workspace 1..10" \
  "" \
  "Help" \
  "  SUPER + F1       Show this keybind help" \
  | wofi --dmenu --prompt "Hyprland keybinds" --insensitive >/dev/null
