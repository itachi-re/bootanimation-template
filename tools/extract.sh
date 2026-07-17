#!/usr/bin/env bash
# tools/extract.sh
#
# Extracts a bootanimation.zip into a working frames directory for editing or
# porting. Supports --unwrap for OEM firmware that nests the real animation
# ZIP inside a proprietary container (observed on some HyperOS/MIUI regional
# builds) -- when passed, it first scans for an inner ZIP containing desc.txt
# and extracts that instead of the outer container.
#
# Usage:
#   tools/extract.sh <bootanimation.zip> <output_dir> [--unwrap]

set -euo pipefail

IN_ZIP="${1:-}"
OUT_DIR="${2:-}"
UNWRAP="${3:-}"

if [ -z "$IN_ZIP" ] || [ -z "$OUT_DIR" ]; then
  echo "Usage: $0 <bootanimation.zip> <output_dir> [--unwrap]" >&2
  exit 2
fi

if [ ! -f "$IN_ZIP" ]; then
  echo "ERROR: file not found: $IN_ZIP" >&2
  exit 1
fi

SOURCE_ZIP="$IN_ZIP"

if [ "$UNWRAP" = "--unwrap" ]; then
  if unzip -l "$IN_ZIP" | grep -q "desc.txt"; then
    echo "Note: --unwrap given but desc.txt already found at top level; ignoring --unwrap."
  else
    INNER=$(unzip -l "$IN_ZIP" | awk '$NF ~ /\.zip$/ {print $NF}' | head -n1)
    if [ -z "$INNER" ]; then
      echo "ERROR: --unwrap given but no inner .zip found inside $IN_ZIP" >&2
      exit 1
    fi
    echo "Unwrapping inner archive: $INNER"
    TMP_UNWRAP=$(mktemp -d)
    unzip -q -j "$IN_ZIP" "$INNER" -d "$TMP_UNWRAP"
    SOURCE_ZIP="$TMP_UNWRAP/$(basename "$INNER")"
  fi
fi

mkdir -p "$OUT_DIR"
unzip -q "$SOURCE_ZIP" -d "$OUT_DIR"

if [ ! -f "$OUT_DIR/desc.txt" ]; then
  echo "WARNING: extraction finished but no desc.txt found at $OUT_DIR -- this may not be a valid boot animation, or may need --unwrap." >&2
fi

echo "Extracted to: $OUT_DIR"
echo "Frame counts per part:"
for part in "$OUT_DIR"/part*/; do
  [ -d "$part" ] || continue
  count=$(find "$part" -maxdepth 1 -name '*.png' | wc -l | tr -d ' ')
  echo "  $(basename "$part"): $count frame(s)"
done
