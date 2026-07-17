# Creating a Boot Animation

## How Android boot animations work

Android's `bootanimation` binary (part of AOSP, `frameworks/base/cmds/bootanimation`) reads a ZIP file — uncompressed or with `STORE`-only compression — containing a `desc.txt` file and a set of numbered part folders (`part0`, `part1`, `part2`, ...), each holding a sequence of PNG frames. The binary plays each part in order, according to the rules in `desc.txt`, and loops the final part until the system finishes booting (`sys.boot_completed` is set).

## `desc.txt` syntax

```
<width> <height> <fps>
p <loop-count> <pause-frames> <part-folder>
p <loop-count> <pause-frames> <part-folder>
```

- **width / height** — must match your PNG frame dimensions exactly, or Android will letterbox or crop the animation.
- **fps** — typically 30 or 60. Higher FPS increases file size significantly with no visible benefit above your display's refresh rate.
- **loop-count** — `0` means infinite loop (used for the final part, which plays until boot completes). Any other number is a fixed repeat count.
- **pause-frames** — number of frames to hold on the last frame of that part before continuing.
- **part-folder** — the directory name (e.g. `part0`) containing that part's PNG sequence.

Example:
```
1080 2400 60
p 1 0 part0
p 0 0 part1
```
This plays `part0` once, then loops `part1` forever until boot completes.

## ZIP structure requirements

```
bootanimation.zip
├── desc.txt
├── part0/
│   ├── 00000.png
│   ├── 00001.png
│   └── ...
└── part1/
    ├── 00000.png
    └── ...
```

- The ZIP **must** be created with `STORE` (no compression) for `desc.txt` and part folders in most AOSP implementations, or the animation will fail to load. `tools/pack.sh` (referenced by `build.sh`) handles this correctly by default.
- Frame filenames must be sequential and zero-padded consistently within a part.
- Mixing resolutions between frames in the same part is not supported.

## PNG optimization

Boot animation ZIPs are read early in boot, before most of the filesystem cache is warm, so file size directly affects animation smoothness on lower-end devices. `tools/optimize_png.sh` runs lossless PNG compression (palette reduction where safe) across a frame sequence before packing. As a rule of thumb, keep total ZIP size under ~15 MB for reliable playback on entry-level hardware.

## Previewing safely

`tools/preview.sh`:

1. Backs up the current boot animation ZIP at the detected path.
2. Bind-mounts your candidate `bootanimation.zip` over that path.
3. Starts the `bootanim` service directly (`setprop ctl.start bootanim`) without a full reboot.
4. Waits for a configurable duration (default: length implied by your `desc.txt`, or 15s if undetectable).
5. Stops the service and **unmounts**, restoring the original file untouched.

This never modifies the actual partition contents, so a bad animation can't cause a bootloop during preview.

## Previews and screenshots

- `preview.gif` — short looping preview for quick viewing on GitHub (a few seconds, low frame count is fine).
- `preview.webp` — higher-quality preview, smaller file size than GIF for the same quality.
- `screenshots/` — actual device photos or screen recordings, useful for verifying real-device rendering (letterboxing, cropping, color accuracy).

## Dark and shutdown variants

Add `bootanimation-dark.zip` and/or `shutdownanimation.zip` / `shutdownanimation-dark.zip` alongside the primary ZIP in `assets/`, and set the corresponding flags in `metadata.yml`. The installer applies these only on ROMs that support the relevant feature; unsupported ROMs simply skip the variant without error.

## Porting between resolutions

To port an existing animation to a different screen resolution:

1. Extract frames with `tools/extract.sh`.
2. Resize/crop with `tools/resize.py`, preserving aspect ratio (letterboxing is generally preferable to stretching for readability of any text/logo elements).
3. Update `width`/`height` in `desc.txt` to match exactly.
4. Re-pack with `tools/pack.sh` and re-validate with `tools/validate.sh`.
