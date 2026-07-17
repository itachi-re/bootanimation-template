#!/usr/bin/env bash
# tools/pack.sh
#
# Packs a source directory (containing desc.txt and part0/, part1/, ... PNG
# sequence folders) into a bootanimation.zip using STORE-only compression,
# which is required for Android's bootanimation binary to read it correctly.
#
# Usage:
#   tools/pack.sh <source_dir> <output.zip>
#
# Example:
#   tools/pack.sh assets/frames/ assets/bootanimation.zip

set -euo pipefail

SRC_DIR="${1:-}"
OUT_ZIP="${2:-}"

if [ -z "$SRC_DIR" ] || [ -z "$OUT_ZIP" ]; then
  echo "Usage: $0 <source_dir> <output.zip>" >&2
  exit 2
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "ERROR: source directory not found: $SRC_DIR" >&2
  exit 1
fi

if [ ! -f "$SRC_DIR/desc.txt" ]; then
  echo "ERROR: $SRC_DIR/desc.txt not found -- refusing to pack an animation without it" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT_ZIP")"
ABS_OUT="$(cd "$(dirname "$OUT_ZIP")" && pwd)/$(basename "$OUT_ZIP")"
rm -f "$ABS_OUT"

# desc.txt MUST be the first entry in the archive per the AOSP bootanimation
# reader's expectations, and everything must be stored (-0), not deflated.
(
  cd "$SRC_DIR"
  zip -q -0 -X "$ABS_OUT" desc.txt
  for part_dir in part*/; do
    [ -d "$part_dir" ] || continue
    zip -q -0 -X -r "$ABS_OUT" "${part_dir%/}"
  done
)

echo "Packed: $ABS_OUT"
echo "Verify with: tools/validate.sh $ABS_OUT"
