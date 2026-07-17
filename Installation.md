# Installation

## Requirements

- A rooted Android device running one of: **Magisk**, **KernelSU**, or **APatch**
- Android 8 through 16
- BusyBox (bundled with virtually all modern root managers — no separate install needed)

## Installing a built module

1. Download the release ZIP from the repository's **Releases** page (or build one yourself — see [`Packaging.md`](Packaging.md)).
2. Open your root manager's app:
   - **Magisk:** Modules → Install from storage → select the ZIP → reboot.
   - **KernelSU:** Modules → Install → select the ZIP → reboot.
   - **APatch:** Modules → Install → select the ZIP → reboot.
3. On first boot after install, the installer runs `customize.sh`, which:
   - Detects Android version, API level, and CPU architecture
   - Detects which root manager is active
   - Locates the correct boot-animation partition for your device/ROM
   - Validates the bundled `bootanimation.zip`
   - Checks for and safely disables conflicting boot-animation modules
   - Prints an installation summary to the manager's install log

## Reading the install log

A successful install ends with a summary block similar to:

```
====================================
 bootanimation-template install summary
====================================
 Root manager      : Magisk
 Android version    : 14 (API 34)
 Architecture        : arm64-v8a
 Target path         : /system/product/media
 Dark animation     : yes
 Shutdown animation : no
 Conflicts resolved  : 1 (disabled: old-bootanim-module)
 Validation           : PASSED
====================================
```

If validation fails, the installer aborts **before** touching the system partition and prints the specific reason (see [`Troubleshooting.md`](Troubleshooting.md)).

## Uninstalling

Disable or remove the module from your root manager's Modules screen and reboot. `uninstall.sh` restores any boot animation that was backed up during install, and re-enables any module that was disabled due to a conflict.

## Verifying installation

After rebooting, your new boot animation should play immediately. If it doesn't:

1. Confirm the module shows as **active** (not just installed) in your root manager.
2. Run `tools/check_bootanimation.sh` from an ADB shell to confirm the ZIP is present at the detected path and is readable by the `system` user.
3. See [`Troubleshooting.md`](Troubleshooting.md) for the full diagnostic flow.
