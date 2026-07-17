#!/usr/bin/env bash
# tools/build.sh
#
# Assembles the flashable module ZIP from module/, mirroring exactly what
# customize.sh expects to find at MODPATH during installation. The staged
# ZIP has module.prop, META-INF/, etc. at its OWN root (not nested under a
# "module/" folder) -- that nesting only exists in this repo for organization
# and must not appear in the flashed artifact, or Magisk/KernelSU/APatch
# won't find module.prop.
#
# Run tools/validate.sh yourself beforehand -- this script does not
# re-validate the animation, to keep build and validate as separate,
# composable steps.
#
# Usage:
#   tools/build.sh
#
# Output: dist/<module-id>-<version>.zip  (dist/ lives at repo root, not under module/)

set -euo pipefail

cd "$(dirname "$0")/.."   # repo root
MODULE_DIR="module"

if [ ! -d "$MODULE_DIR" ]; then
  echo "ERROR: $MODULE_DIR/ not found. Expected the flashable payload under module/." >&2
  exit 1
fi

if [ ! -f "$MODULE_DIR/assets/bootanimation.zip" ]; then
  echo "ERROR: $MODULE_DIR/assets/bootanimation.zip not found. Add your animation before building." >&2
  exit 1
fi

MODULE_ID=$(grep '^id=' "$MODULE_DIR/module.prop" | cut -d= -f2)
VERSION=$(grep '^version=' "$MODULE_DIR/module.prop" | cut -d= -f2)

if [ -z "$MODULE_ID" ] || [ -z "$VERSION" ]; then
  echo "ERROR: could not read id/version from $MODULE_DIR/module.prop" >&2
  exit 1
fi

DIST_DIR="dist"
OUT_ZIP="$DIST_DIR/${MODULE_ID}-${VERSION}.zip"

mkdir -p "$DIST_DIR"
rm -f "$OUT_ZIP"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "Staging module contents from $MODULE_DIR/ ..."
cp "$MODULE_DIR/module.prop" "$STAGE/"
cp "$MODULE_DIR/system.prop" "$STAGE/"
cp "$MODULE_DIR/customize.sh" "$STAGE/"
cp "$MODULE_DIR/uninstall.sh" "$STAGE/"
cp "$MODULE_DIR/service.sh" "$STAGE/"
cp "$MODULE_DIR/post-fs-data.sh" "$STAGE/"

mkdir -p "$STAGE/META-INF/com/google/android"
cp "$MODULE_DIR/META-INF/com/google/android/update-binary" "$STAGE/META-INF/com/google/android/"
cp "$MODULE_DIR/META-INF/com/google/android/updater-script" "$STAGE/META-INF/com/google/android/"

mkdir -p "$STAGE/assets"
cp "$MODULE_DIR/assets/bootanimation.zip" "$STAGE/assets/"
[ -f "$MODULE_DIR/assets/bootanimation-dark.zip" ] && cp "$MODULE_DIR/assets/bootanimation-dark.zip" "$STAGE/assets/"
[ -f "$MODULE_DIR/assets/shutdownanimation.zip" ] && cp "$MODULE_DIR/assets/shutdownanimation.zip" "$STAGE/assets/"
[ -f "$MODULE_DIR/assets/shutdownanimation-dark.zip" ] && cp "$MODULE_DIR/assets/shutdownanimation-dark.zip" "$STAGE/assets/"

chmod 0755 "$STAGE"/*.sh

echo "Packing $OUT_ZIP ..."
(
  cd "$STAGE"
  zip -q -r -X "$OLDPWD/$OUT_ZIP" . -x '.*'
)

echo "Built: $OUT_ZIP"
echo "Verify module.prop sits at the ZIP root (not nested):"
echo "  unzip -l \"$OUT_ZIP\" | grep module.prop"
echo "Install with: adb push \"$OUT_ZIP\" /data/local/tmp/ && adb shell su -c \"magisk --install-module /data/local/tmp/$(basename "$OUT_ZIP")\""
echo "(or sideload through your root manager's app UI)"
