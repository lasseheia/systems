set -eu

SNAPSHOT_DIR="$HOME/.local/share/opencode/snapshot"
MAX_BYTES=$((10 * 1024 * 1024 * 1024))
RETAIN_DAYS=14

if [ ! -d "$SNAPSHOT_DIR" ]; then
  exit 0
fi

find "$SNAPSHOT_DIR" -type f \( -name 'tmp_pack_*' -o -name '.tmp-*-pack-*' \) -delete
find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d -mtime "+$RETAIN_DAYS" -exec rm -rf {} +

current_bytes="$(du -sb "$SNAPSHOT_DIR" | cut -f1)"
if [ "$current_bytes" -gt "$MAX_BYTES" ]; then
  rm -rf "$SNAPSHOT_DIR"/* "$SNAPSHOT_DIR"/.[!.]* "$SNAPSHOT_DIR"/..?* 2>/dev/null || true
fi
