#!/system/bin/sh
# shellcheck shell=dash
#
# tools/check_boot_m.sh
# On-device tool that reports the boot-animation path the *running system*
# actually reads from, as opposed to the static candidate list customize.sh
# probes. Useful for heavily customized OEM builds where none of the standard
# candidates match. Run via:
#   adb shell su -c "sh /path/to/check_boot_m.sh"

echo "==== boot-animation mount inspection ===="
echo ""

echo "-- Mounts referencing 'media' directories --"
mount 2>/dev/null | grep -i media || echo "(none found in mount table)"

echo ""
echo "-- SELinux context of known candidate paths --"
for c in /system/product/media /product/media /system_ext/media /vendor/media /odm/media /my_product/media /system/media; do
  if [ -d "$c" ]; then
    ctx=$(ls -Zd "$c" 2>/dev/null | awk '{print $1}')
    echo "$c -> $ctx"
  fi
done

echo ""
echo "-- Process holding bootanim service --"
ps -A 2>/dev/null | grep bootanim || echo "(bootanim not currently running -- expected after boot completes)"

echo ""
echo "-- init.svc.bootanim property --"
getprop init.svc.bootanim 2>/dev/null || echo "unknown"

echo ""
echo "-- Partition list (for reference) --"
cat /proc/mounts 2>/dev/null | awk '{print $1, $2}' | grep -E '(system|product|vendor|odm)' || true
