#!/usr/bin/env bash
# tools/validate.sh
#
# Validates a bootanimation.zip against the requirements documented in
# docs/Creating.md: correct compression, presence of desc.txt, well-formed
# part folders, sequential/non-duplicate frame numbering, and a desc.txt
# resolution/FPS that at least looks sane.
#
# Usage:
#   tools/validate.sh path/to/bootanimation.zip [--verbose]

set -euo pipefail

ZIP_PATH="${1:-}"
VERBOSE="${2:-}"

if [ -z "$ZIP_PATH" ]; then
  echo "Usage: $0 <bootanimation.zip> [--verbose]" >&2
  exit 2
fi

if [ ! -f "$ZIP_PATH" ]; then
  echo "ERROR: file not found: $ZIP_PATH" >&2
  exit 1
fi

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

log_v() {
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "  [v] $1"
  fi
}

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

echo "Validating: $ZIP_PATH"

# ---- 1. Archive integrity ----
if ! unzip -t "$ZIP_PATH" >/dev/null 2>&1; then
  fail "archive is corrupt or unreadable"
fi
log_v "archive integrity OK"

# ---- 2. Compression method (desc.txt and part folders must be STORE) ----
COMPRESSED_ENTRIES=$(unzip -v "$ZIP_PATH" | awk 'NR>3 && $2 !~ /Stored/ && $NF ~ /\.(txt|png)$/ {print $NF}' || true)
if [ -n "$COMPRESSED_ENTRIES" ]; then
  echo "$COMPRESSED_ENTRIES" | while read -r entry; do
    log_v "compressed (should be stored): $entry"
  done
  fail "one or more entries use deflate compression instead of STORE -- repack with tools/pack.sh"
fi
log_v "compression method OK (STORE)"

# ---- 3. desc.txt presence and syntax ----
unzip -p "$ZIP_PATH" desc.txt > "$WORKDIR/desc.txt" 2>/dev/null || fail "desc.txt not found in archive"

DESC_LINE1=$(head -n1 "$WORKDIR/desc.txt")
WIDTH=$(echo "$DESC_LINE1" | awk '{print $1}')
HEIGHT=$(echo "$DESC_LINE1" | awk '{print $2}')
FPS=$(echo "$DESC_LINE1" | awk '{print $3}')

if ! [[ "$WIDTH" =~ ^[0-9]+$ ]] || ! [[ "$HEIGHT" =~ ^[0-9]+$ ]] || ! [[ "$FPS" =~ ^[0-9]+$ ]]; then
  fail "desc.txt header line is malformed (expected: '<width> <height> <fps>'), got: '$DESC_LINE1'"
fi
log_v "desc.txt header OK: ${WIDTH}x${HEIGHT} @ ${FPS}fps"

if [ "$FPS" -lt 1 ] || [ "$FPS" -gt 120 ]; then
  fail "FPS value ($FPS) looks invalid -- expected between 1 and 120"
fi

PART_LINES=$(grep -c '^p ' "$WORKDIR/desc.txt" || true)
if [ "$PART_LINES" -lt 1 ]; then
  fail "desc.txt contains no 'p' (part) lines"
fi
log_v "found $PART_LINES part line(s) in desc.txt"

# ---- 4. part folders exist and match desc.txt references ----
mkdir -p "$WORKDIR/extracted"
unzip -q "$ZIP_PATH" -d "$WORKDIR/extracted"

grep '^p ' "$WORKDIR/desc.txt" | while read -r _p loop pause part; do
  PART_DIR="$WORKDIR/extracted/$part"
  if [ ! -d "$PART_DIR" ]; then
    fail "desc.txt references '$part' but no such folder exists in the archive"
  fi

  FRAME_COUNT=$(find "$PART_DIR" -maxdepth 1 -name '*.png' | wc -l | tr -d ' ')
  if [ "$FRAME_COUNT" -eq 0 ]; then
    fail "part '$part' contains no PNG frames"
  fi
  log_v "part '$part': $FRAME_COUNT frame(s), loop=$loop pause=$pause"

  # Check for duplicate frame filenames (case-insensitive collisions) and
  # gaps in numeric sequence where filenames are purely numeric.
  # -printf is GNU-find-only; fall back to a null-delimited loop (not xargs,
  # which would mishandle filenames containing spaces/newlines -- SC2038) on
  # find implementations without it (e.g. BSD/macOS find).
  if find "$PART_DIR" -maxdepth 1 -name '*.png' -printf '%f\n' > "$WORKDIR/frames_$part.txt" 2>/dev/null; then
    sort -o "$WORKDIR/frames_$part.txt" "$WORKDIR/frames_$part.txt"
  else
    : > "$WORKDIR/frames_$part.txt"
    while IFS= read -r -d '' entry; do
      basename "$entry" >> "$WORKDIR/frames_$part.txt"
    done < <(find "$PART_DIR" -maxdepth 1 -name '*.png' -print0)
    sort -o "$WORKDIR/frames_$part.txt" "$WORKDIR/frames_$part.txt"
  fi

  DUPES=$(sort "$WORKDIR/frames_$part.txt" | uniq -d)
  if [ -n "$DUPES" ]; then
    fail "part '$part' has duplicate frame filenames: $DUPES"
  fi
done

echo "PASS: $ZIP_PATH is a valid boot animation."
echo "  Resolution : ${WIDTH}x${HEIGHT}"
echo "  FPS          : ${FPS}"
echo "  Parts        : ${PART_LINES}"
