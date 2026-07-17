#!/system/bin/sh
# shellcheck shell=dash
#
# post-fs-data.sh
# Runs at post-fs-data, before most system services start. The module's file
# overlay (systemless mount) is already handled by the root manager itself at
# this stage -- this script exists only to log a diagnostic marker used by
# tools/check_bootanimation.sh, and to guard against a partially-installed
# module (missing bootanimation.zip) from silently reaching boot.

MODDIR=${0%/*}
LOGFILE="/data/adb/bootanimation_template.log"

{
  echo "[post-fs-data] $(date 2>/dev/null || echo unknown-time)"
  if [ -f "$MODDIR/system/media/bootanimation.zip" ] || \
     find "$MODDIR" -name "bootanimation.zip" -print -quit 2>/dev/null | grep -q .; then
    echo "[post-fs-data] bootanimation.zip present in module overlay: OK"
  else
    echo "[post-fs-data] WARNING: bootanimation.zip missing from module overlay"
  fi
} >> "$LOGFILE" 2>&1
