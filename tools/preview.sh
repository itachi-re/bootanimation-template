#!/usr/bin/env bash
# tools/preview.sh
#
# Previews a bootanimation.zip on a connected, rooted device via ADB, without
# rebooting and without permanently modifying the device's boot animation.
# It bind-mounts the candidate ZIP over the detected live path, starts the
# bootanim service, waits, then always unmounts and restores state -- even on
# failure (via a remote trap).
#
# Usage:
#   tools/preview.sh [path/to/bootanimation.zip] [duration_seconds]
#
# Defaults to assets/bootanimation.zip and a 15s preview window.

set -euo pipefail

ZIP_PATH="${1:-assets/bootanimation.zip}"
DURATION="${2:-15}"
REMOTE_TMP="/data/local/tmp/preview_bootanimation.zip"

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb not found in PATH." >&2
  exit 1
fi

if [ ! -f "$ZIP_PATH" ]; then
  echo "ERROR: $ZIP_PATH not found." >&2
  exit 1
fi

if ! adb get-state >/dev/null 2>&1; then
  echo "ERROR: no device connected (adb get-state failed)." >&2
  exit 1
fi

echo "Pushing $ZIP_PATH to device..."
adb push "$ZIP_PATH" "$REMOTE_TMP" >/dev/null

echo "Running remote preview (duration: ${DURATION}s)..."

# The remote script runs entirely as root via `su -c`, detects the live
# boot-animation path the same way customize.sh does, bind-mounts the
# preview ZIP over it, restarts the bootanim service, waits, then restores
# the original file via a trap that fires on any exit path (including
# Ctrl-C on the host, which ADB forwards as a shell termination).
adb shell su -c "sh -c '
set -e
CANDIDATES=\"/system/product/media /product/media /system_ext/media /vendor/media /odm/media /my_product/media /system/media\"
TARGET=\"\"
for c in \$CANDIDATES; do
  if [ -f \"\$c/bootanimation.zip\" ]; then
    TARGET=\"\$c/bootanimation.zip\"
    break
  fi
done
if [ -z \"\$TARGET\" ]; then
  echo \"No existing bootanimation.zip found on any known path -- cannot preview safely.\"
  exit 1
fi
echo \"Live path: \$TARGET\"

cleanup() {
  umount \"\$TARGET\" 2>/dev/null
  setprop ctl.stop bootanim
  echo \"Restored original animation.\"
}
trap cleanup EXIT INT TERM

mount --bind $REMOTE_TMP \"\$TARGET\"
setprop ctl.stop bootanim
setprop ctl.start bootanim
echo \"Previewing for ${DURATION}s...\"
sleep ${DURATION}
'"

echo "Cleaning up remote temp file..."
adb shell rm -f "$REMOTE_TMP" >/dev/null 2>&1 || true

echo "Preview complete. Original boot animation restored."
