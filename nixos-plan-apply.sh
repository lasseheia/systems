#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <apply> <repo_root> <host>" >&2
  exit 1
fi

action="$1"
repo_root="$2"
host="$3"

flake_attr="${repo_root}/hosts/${host}#nixosConfigurations.${host}.config.system.build.toplevel"

diff_closure() {
  local target="$1"
  if command -v nvd >/dev/null 2>&1; then
    nvd diff /run/current-system "${target}"
  else
    nix store diff-closures /run/current-system "${target}"
  fi
}

if [[ "${action}" != "apply" ]]; then
  echo "Unknown action: ${action}" >&2
  echo "Usage: $0 <apply> <repo_root> <host>" >&2
  exit 1
fi

planned_path="$(nix build --no-link --print-out-paths "${flake_attr}")"

echo
echo "Planned system path: ${planned_path}"
echo
echo "--- Closure diff (current -> planned) ---"
diff_closure "${planned_path}"
echo
echo "--- Activation preview ---"
sudo "${planned_path}/bin/switch-to-configuration" dry-activate
echo
read -r -p "Apply these changes to ${host}? [y/N] " answer
if [[ "${answer}" != "y" && "${answer}" != "Y" ]]; then
  echo "Apply cancelled."
  exit 0
fi

sudo nix-env -p /nix/var/nix/profiles/system --set "${planned_path}"
sudo "${planned_path}/bin/switch-to-configuration" switch
echo
echo "Applied planned system for ${host}."
