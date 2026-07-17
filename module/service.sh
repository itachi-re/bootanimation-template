#!/system/bin/sh
# shellcheck shell=dash
#
# service.sh
# Runs at late_start service stage (after boot_completed is not yet true, but
# most services are up). Boot animation playback itself is handled entirely
# by the system's bootanim service reading the overlaid file -- nothing here
# needs to trigger playback. This script only performs a final sanity check
# and writes it to the module log, so a broken install is diagnosable from
# `adb shell cat /data/adb/bootanimation_template.log` without needing a
# reboot loop to reproduce.

MODDIR=${0%/*}
LOGFILE="/data/adb/bootanimation_template.log"

# Wait briefly for boot animation service state to settle before checking.
sleep 2

{
  echo "[service] $(date 2>/dev/null || echo unknown-time)"
  BOOTANIM_STATE=$(getprop init.svc.bootanim 2>/dev/null || echo "unknown")
  echo "[service] bootanim service state: $BOOTANIM_STATE"
  echo "[service] module dir: $MODDIR"
} >> "$LOGFILE" 2>&1
