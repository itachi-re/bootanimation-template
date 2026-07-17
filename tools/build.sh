#!/usr/bin/env bash
# tools/build.sh
#
# Assembles the flashable module ZIP from module.prop, the installer scripts,
# META-INF, and assets/, mirroring exactly what customize.sh expects to find
# at MODPATH during installation. Run tools/validate.sh yourself beforehand --
# this script does not re-validate the animation, to keep build and validate
# as separate, composable steps.
#
# Usage:
#   tools/build.sh
#
# Output: dist/<module-id>-<version>.zip

set -euo pipefail

cd "$(dirname "$0")/.."   # repo root

if [ ! -f assets/bootanimation.zip ]; then
  echo "ERROR: assets/bootanimation.zip not found. Add your animation before building." >&2
  exit 1
fi

MODULE_ID=$(grep '^id=' module.prop | cut -d= -f2)
VERSION=$(grep '^version=' module.prop | cut -d= -f2)

if [ -z "$MODULE_ID" ] || [ -z "$VERSION" ]; then
  echo "ERROR: could not read id/version from module.prop" >&2
  exit 1
fi

DIST_DIR="dist"
OUT_ZIP="$DIST_DIR/${MODULE_ID}-${VERSION}.zip"

mkdir -p "$DIST_DIR"
rm -f "$OUT_ZIP"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "Staging module contents..."
cp module.prop "$STAGE/"
cp system.prop "$STAGE/"
cp customize.sh "$STAGE/"
cp uninstall.sh "$STAGE/"
cp service.sh "$STAGE/"
cp post-fs-data.sh "$STAGE/"

mkdir -p "$STAGE/META-INF/com/google/android"
cp META-INF/com/google/android/update-binary "$STAGE/META-INF/com/google/android/"
cp META-INF/com/google/android/updater-script "$STAGE/META-INF/com/google/android/"

mkdir -p "$STAGE/assets"
cp assets/bootanimation.zip "$STAGE/assets/"
[ -f assets/bootanimation-dark.zip ] && cp assets/bootanimation-dark.zip "$STAGE/assets/"
[ -f assets/shutdownanimation.zip ] && cp assets/shutdownanimation.zip "$STAGE/assets/"
[ -f assets/shutdownanimation-dark.zip ] && cp assets/shutdownanimation-dark.zip "$STAGE/assets/"

chmod 0755 "$STAGE"/*.sh

echo "Packing $OUT_ZIP ..."
(
  cd "$STAGE"
  zip -q -r -X "$OLDPWD/$OUT_ZIP" . -x '.*'
)

echo "Built: $OUT_ZIP"
echo "Install with: adb push \"$OUT_ZIP\" /data/local/tmp/ && adb shell su -c \"magisk --install-module /data/local/tmp/$(basename "$OUT_ZIP")\""
echo "(or sideload through your root manager's app UI)"
