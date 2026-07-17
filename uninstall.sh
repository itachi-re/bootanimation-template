#!/system/bin/sh
# shellcheck shell=dash
#
# uninstall.sh
# Runs when the module is removed. Because the boot animation is applied via
# a systemless overlay (never a direct write to the real partition), there is
# nothing to "restore" for the animation file itself -- removing the module
# removes the overlay and the original ROM/OEM animation becomes visible
# again automatically.
#
# The one piece of state this script IS responsible for cleaning up: any
# conflicting boot-animation modules that customize.sh disabled during
# install. Those get re-enabled here so uninstalling this module doesn't
# leave a previously-working module permanently disabled.

RECORD="/data/adb/bootanimation_template_disabled.list"

if [ -f "$RECORD" ]; then
  while IFS= read -r modname; do
    [ -z "$modname" ] && continue
    disable_flag="/data/adb/modules/$modname/disable"
    if [ -f "$disable_flag" ]; then
      rm -f "$disable_flag"
    fi
  done < "$RECORD"
  rm -f "$RECORD"
fi

rm -f /data/adb/bootanimation_template.log
