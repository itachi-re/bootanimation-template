#!/system/bin/sh
# shellcheck shell=dash
#
# customize.sh
# Runs inside the root manager's installer shell (BusyBox ash) during module
# installation. Detects the environment, locates the correct boot-animation
# path, validates the bundled bootanimation.zip, resolves conflicts with other
# boot-animation modules, installs, and prints a summary.
#
# Provided by the installer environment: MODPATH, TMPDIR, MODID (var names
# differ slightly between managers; we normalize below).

set -u

##############################################
# Candidate boot-animation partition paths,
# checked in priority order.
##############################################
BOOTANIM_CANDIDATES="
/system/product/media
/product/media
/system_ext/media
/vendor/media
/odm/media
/my_product/media
/system/media
"

##############################################
# Helpers
##############################################

log() {
  ui_print "  $1"
}

section() {
  ui_print "-----------------------------------"
  ui_print " $1"
  ui_print "-----------------------------------"
}

abort_install() {
  ui_print "! ERROR: $1"
  abort "  Installation stopped -- system partition was not modified."
}

##############################################
# 1. Detect root manager
##############################################
detect_root_manager() {
  if [ -n "${KSU:-}" ]; then
    echo "KernelSU"
  elif [ -n "${APATCH:-}" ]; then
    echo "APatch"
  elif [ -n "${MAGISK_VER_CODE:-}" ]; then
    echo "Magisk"
  else
    echo "Unknown"
  fi
}

##############################################
# 2. Detect Android version / API / arch
##############################################
detect_android_release() {
  getprop ro.build.version.release 2>/dev/null || echo "unknown"
}

detect_api_level() {
  getprop ro.build.version.sdk 2>/dev/null || echo "0"
}

detect_arch() {
  getprop ro.product.cpu.abi 2>/dev/null || echo "unknown"
}

##############################################
# 3. Detect BusyBox
##############################################
detect_busybox() {
  if command -v busybox >/dev/null 2>&1; then
    echo "yes"
  else
    echo "no"
  fi
}

##############################################
# 4. Detect boot-animation target path
#    Picks the first existing, writable-parent
#    candidate. Falls back to /system/media
#    if none appear pre-populated (fresh AVDs
#    sometimes have none until first write).
##############################################
detect_bootanim_path() {
  target=""
  for candidate in $BOOTANIM_CANDIDATES; do
    if [ -d "$candidate" ]; then
      target="$candidate"
      break
    fi
  done
  if [ -z "$target" ]; then
    target="/system/media"
  fi
  echo "$target"
}

##############################################
# 5. Detect conflicting boot-animation modules
#    A conflict = another active module that
#    also ships a module-provided bootanimation
#    at the same detected path.
##############################################
MODULES_ROOT="/data/adb/modules"
CONFLICTS=""

detect_conflicts() {
  [ -d "$MODULES_ROOT" ] || return 0
  for dir in "$MODULES_ROOT"/*; do
    [ -d "$dir" ] || continue
    base=$(basename "$dir")
    [ "$base" = "$MODID" ] && continue
    [ -e "$dir/disable" ] && continue
    if [ -f "$dir/system/media/bootanimation.zip" ] || \
       [ -f "$dir$TARGET_PATH/bootanimation.zip" ]; then
      CONFLICTS="$CONFLICTS $base"
    fi
  done
}

disable_conflicts() {
  [ -z "$CONFLICTS" ] && return 0
  # Record which modules we disabled so uninstall.sh can re-enable exactly
  # those, and no others, on removal.
  : > /data/adb/bootanimation_template_disabled.list
  for c in $CONFLICTS; do
    log "Disabling conflicting module: $c"
    touch "$MODULES_ROOT/$c/disable" 2>/dev/null
    echo "$c" >> /data/adb/bootanimation_template_disabled.list
  done
}

##############################################
# 6. Lightweight ZIP validation
#    (Full validation lives in tools/validate.sh
#    for development use; this is the minimal
#    on-device safety check run at install time.)
##############################################
validate_bootanimation() {
  zip_path="$1"
  [ -f "$zip_path" ] || abort_install "bootanimation.zip not found in module payload."

  if ! unzip -l "$zip_path" >/dev/null 2>&1; then
    abort_install "bootanimation.zip is corrupt or unreadable."
  fi

  if ! unzip -l "$zip_path" | grep -q "desc.txt"; then
    abort_install "bootanimation.zip is missing desc.txt."
  fi

  if ! unzip -l "$zip_path" | grep -q "part0/"; then
    abort_install "bootanimation.zip is missing part0/ -- no frames to play."
  fi
}

##############################################
# Main
##############################################

# Normalize MODID across managers (Magisk exposes $MODPATH's basename;
# KernelSU/APatch expose $MODID directly in most builds).
MODID="${MODID:-$(basename "$MODPATH")}"

section "bootanimation-template installer"

ROOT_MANAGER=$(detect_root_manager)
ANDROID_RELEASE=$(detect_android_release)
API_LEVEL=$(detect_api_level)
ARCH=$(detect_arch)
BUSYBOX_PRESENT=$(detect_busybox)
TARGET_PATH=$(detect_bootanim_path)

log "Root manager      : $ROOT_MANAGER"
log "Android version    : $ANDROID_RELEASE (API $API_LEVEL)"
log "Architecture         : $ARCH"
log "BusyBox present   : $BUSYBOX_PRESENT"
log "Target path         : $TARGET_PATH"

if [ "$API_LEVEL" -lt 26 ] 2>/dev/null; then
  abort_install "Android API $API_LEVEL is below the minimum supported (26 / Android 8)."
fi

section "Validating bundled animation"
validate_bootanimation "$MODPATH/assets/bootanimation.zip"
log "Validation           : PASSED"

section "Checking for conflicting modules"
detect_conflicts
if [ -n "$CONFLICTS" ]; then
  log "Conflicts found    :$CONFLICTS"
  disable_conflicts
else
  log "Conflicts found    : none"
fi

section "Installing"
mkdir -p "$MODPATH$TARGET_PATH"
cp -f "$MODPATH/assets/bootanimation.zip" "$MODPATH$TARGET_PATH/bootanimation.zip"

if [ -f "$MODPATH/assets/bootanimation-dark.zip" ]; then
  cp -f "$MODPATH/assets/bootanimation-dark.zip" "$MODPATH$TARGET_PATH/bootanimation-dark.zip"
  log "Dark animation      : installed"
fi

if [ -f "$MODPATH/assets/shutdownanimation.zip" ]; then
  cp -f "$MODPATH/assets/shutdownanimation.zip" "$MODPATH$TARGET_PATH/shutdownanimation.zip"
  log "Shutdown animation  : installed"
fi

# assets/ is not needed inside the final systemless overlay
rm -rf "$MODPATH/assets"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH$TARGET_PATH/bootanimation.zip" 0 0 0644

section "Install summary"
log "Root manager      : $ROOT_MANAGER"
log "Android version    : $ANDROID_RELEASE (API $API_LEVEL)"
log "Architecture         : $ARCH"
log "Target path         : $TARGET_PATH"
[ -n "$CONFLICTS" ] && log "Conflicts resolved  :$CONFLICTS"
log "Validation           : PASSED"
ui_print "-----------------------------------"
ui_print " Done. Reboot to see your new boot animation."
ui_print "-----------------------------------"
