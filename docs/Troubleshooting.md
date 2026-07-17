# Troubleshooting

## Bootloop after installing

This is almost never caused by the installer itself, since installation aborts before touching the system partition if validation fails. If a bootloop occurs anyway:

1. Boot into recovery or use your root manager's safe mode (Magisk: hold a volume key combo at boot per your device; KernelSU/APatch: consult their respective safe-mode docs).
2. Disable the module from safe mode.
3. Reboot normally.
4. Collect logs (`adb logcat -b all > log.txt` from the moment of boot, if accessible) and open an issue with your device model, ROM, and root manager version.

## Black screen instead of animation

Usually one of:

- `desc.txt` resolution doesn't match the device's actual display resolution — check with `adb shell wm size`.
- The ZIP was compressed instead of stored — re-pack with `tools/pack.sh`, which stores files correctly.
- The animation was installed to a path the ROM doesn't actually read from — run `tools/check_boot_m.sh` to confirm the *actual* path in use, which may differ from the detected default on heavily customized OEM builds.

## Animation not applying at all (old one still plays)

- Confirm the module is **enabled**, not just installed, in your root manager.
- Some ROMs cache the boot animation; a full reboot (not just service restart) may be required after install.
- Check for a second, conflicting boot-animation module still active — the installer only disables conflicts it detects at install time, not ones added afterward.

## Validation fails with "invalid compression"

Your ZIP was created with default compression. `desc.txt` and the part folders must be stored, not deflated. Use `tools/pack.sh module/assets/frames/ module/assets/bootanimation.zip` rather than a generic `zip` command.

## Validation fails with "frame count mismatch"

A part folder has missing or duplicate frame numbers. Run `tools/validate.sh --verbose` to get the exact missing/duplicate indices.

## Preview mode doesn't restore the original animation

This should not happen under normal operation — `preview.sh` always unmounts in a trap on exit, including on failure. If it does happen (e.g. device lost power mid-preview):

```bash
adb shell su -c "umount <detected-path>/bootanimation.zip"
```

then reboot. Your original file was only bind-mounted over, never deleted, so it is still present underneath.

## Collecting logs for a bug report

```bash
adb logcat -b all -d > full_log.txt
adb shell su -c "cat /data/adb/modules/<module-id>/module.prop"
./tools/check_bootanimation.sh > diagnostic.txt
```

Attach all three to your issue.
