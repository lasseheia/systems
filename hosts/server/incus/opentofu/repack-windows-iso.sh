#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "nix is required." >&2
  exit 1
fi

if ! command -v incus >/dev/null 2>&1; then
  echo "incus is required." >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/../../../.." && pwd)"

source_iso="${repo_root}/Win11_25H2_English_x64.iso"
output_iso="${repo_root}/Win11_25H2_English_x64_repacked.iso"
virtio_iso="${repo_root}/virtio-win.iso"
virtio_url="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
pool="incus"
volume="win11-25h2-repacked"
cache_dir="/tmp/distrobuilder-windows-repack"

tmp_bin="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp_bin}"
}
trap cleanup EXIT

cat >"${tmp_bin}/genisoimage" <<'EOF'
#!/usr/bin/env bash
exec xorrisofs "$@"
EOF
chmod +x "${tmp_bin}/genisoimage"

if [[ ! -f "${source_iso}" ]]; then
  echo "Missing source ISO: ${source_iso}" >&2
  exit 1
fi

if [[ ! -f "${virtio_iso}" ]]; then
  echo "Downloading virtio ISO..."
  curl -L --fail --output "${virtio_iso}" "${virtio_url}"
fi

echo "Repacking Windows ISO..."
rm -rf "${cache_dir}"
PATH="${tmp_bin}:${PATH}" nix shell nixpkgs#distrobuilder nixpkgs#xorriso -c \
  distrobuilder --disable-overlay --cache-dir "${cache_dir}" repack-windows \
  "${source_iso}" "${output_iso}" \
  --drivers="${virtio_iso}" \
  --windows-version=w11 \
  --windows-arch=amd64

if incus storage volume show "${pool}" "${volume}" >/dev/null 2>&1; then
  incus storage volume delete "${pool}" "${volume}"
fi

echo "Importing repacked ISO to ${pool}/${volume}..."
incus storage volume import "${pool}" "${output_iso}" "${volume}" --type=iso

echo "Done: ${pool}/${volume}"
