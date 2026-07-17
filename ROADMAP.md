# Roadmap

## Now (v1.x)

- [x] Core installer with Magisk/KernelSU/APatch support
- [x] Automatic path detection across common OEM layouts
- [x] Conflict detection/resolution with other boot-animation modules
- [x] Local + CI validation tooling
- [x] Full documentation set

## Next

- [ ] `generate_metadata.py` — auto-sync `module.prop` version/id from `metadata.yml` to remove duplicate editing
- [ ] `generate_gallery.py` — build a static gallery page from `metadata.yml` + `preview.webp` for forks that maintain multiple animations in one repo
- [ ] `optimize_png.sh` — automated lossless PNG pass integrated into `tools/build.sh` as an opt-in flag
- [ ] Expand OEM path table as new devices/reports come in via issues

## Later / exploratory

- [ ] Optional GUI companion app for building/previewing without ADB command-line use
- [ ] Signed release artifacts (checksum + signature file alongside each GitHub Release ZIP)
- [ ] Investigate WebP-based frame sequences if/when AOSP's `bootanimation` binary gains broader WebP support upstream (currently PNG-only in mainline AOSP)

## Non-goals

- This repository will not maintain a curated animation library itself — that's intentionally kept in a separate `bootanimations` repository so this template stays lightweight and easy to fork.
- No plans to support non-AOSP-derived boot animation formats (e.g. iOS-style splash video pipelines are out of scope).

Have a suggestion? Open an issue with the `enhancement` label.
