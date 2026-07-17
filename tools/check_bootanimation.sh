#!/system/bin/sh
# shellcheck shell=dash
#
# tools/check_bootanimation.sh
# On-device diagnostic script. Run it via:
#   adb shell su -c "sh /path/to/check_bootanimation.sh"
# (push it first with `adb push tools/check_bootanimation.sh /data/local/tmp/`)
#
# Reports the currently active boot animation file, its size and permissions,
# and whether it passes the same lightweight checks customize.sh runs at
# install time. Intended for attaching output to bug reports.

CANDIDATES="/system/product/media /product/media /system_ext/media /vendor/media /odm/media /my_product/media /system/media"

echo "==== bootanimation-template diagnostic ===="
echo "Date: $(date 2>/dev/null || echo unknown)"
echo ""

FOUND=0
for c in $CANDIDATES; do
  for f in bootanimation.zip bootanimation-dark.zip shutdownanimation.zip shutdownanimation-dark.zip; do
    path="$c/$f"
    if [ -f "$path" ]; then
      FOUND=1
      size=$(wc -c < "$path" 2>/dev/null || echo "unknown")
      perms=$(ls -l "$path" 2>/dev/null | awk '{print $1, $3, $4}')
      echo "FOUND: $path"
      echo "  size  : $size bytes"
      echo "  perms : $perms"
      if unzip -l "$path" 2>/dev/null | grep -q "desc.txt"; then
        echo "  desc.txt : present"
      else
        echo "  desc.txt : MISSING"
      fi
    fi
  done
done

if [ "$FOUND" -eq 0 ]; then
  echo "No boot animation files found on any known path."
fi

echo ""
echo "==== module log (if present) ===="
if [ -f /data/adb/bootanimation_template.log ]; then
  cat /data/adb/bootanimation_template.log
else
  echo "(no log found at /data/adb/bootanimation_template.log)"
fi

echo ""
echo "==== bootanim service state ===="
getprop init.svc.bootanim 2>/dev/null || echo "unknown"
