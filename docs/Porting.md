# Porting Animations Between Devices and ROMs

This document covers porting concerns beyond resolution/aspect-ratio changes (see [`Creating.md`](Creating.md#porting-between-resolutions) for that).

## Porting between OEM skins

Different OEM skins sometimes expect additional metadata or use non-standard `desc.txt` extensions:

- **Samsung OneUI** builds occasionally include a `c` flag on the part line for a "clear" background behavior on AMOLED panels — safe to drop when porting to non-Samsung devices, as it has no effect elsewhere.
- **HyperOS/MIUI** may ship animations bundled with a proprietary container around the standard ZIP on some regional firmware. Extract the inner standard-format ZIP with `tools/extract.sh --unwrap` before working with it.
- Stock **AOSP** and most custom ROMs (LineageOS, crDroid, Evolution X, PixelOS) use the unmodified upstream format described in `Creating.md` with no extensions.

## Porting between root managers

No action is needed — the same module ZIP works across Magisk, KernelSU, and APatch, since `customize.sh` detects the active manager and adapts install paths (`/data/adb/modules/`, `/data/adb/ksu/modules/`, `/data/adb/ap/modules/` respectively) at install time.

## Porting between Android versions

- Android 13+ enforces stricter SELinux contexts on `/product` and `/system_ext`. If your source animation targets an older Android 8–10 device where `/system/media/` was the only location, no changes are needed — the installer's path detection handles the difference automatically.
- Android 15+ has tightened scoped storage further, which does **not** affect boot animation installation directly (it operates at the root/system level, outside scoped storage), but does affect where you can stage files for `adb push` during development — use `/data/local/tmp/` as a staging area, not `/sdcard/`.

## Checklist when porting an existing animation into this template

- [ ] Confirm `desc.txt` resolution matches your target device (or plan to letterbox)
- [ ] Strip any OEM-specific `desc.txt` extensions not needed for your target
- [ ] Re-pack with `tools/pack.sh` to guarantee correct (stored, not deflated) compression
- [ ] Run `tools/validate.sh` against the repacked ZIP
- [ ] Update `metadata.yml` with the correct `android_versions` and `supported_roms` for the new target
- [ ] Preview on the actual target device with `tools/preview.sh` before releasing
