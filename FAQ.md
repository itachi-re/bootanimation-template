# Frequently Asked Questions

## Does this work without root?

No. Boot animations live under `/system/media/` or an equivalent partition, which requires root or a systemless overlay (Magisk, KernelSU, APatch) to modify.

## Which root manager should I use?

Any of the three. The installer scripts detect Magisk, KernelSU, and APatch automatically at install time and adapt accordingly — no manual configuration needed.

## My device isn't listed in Compatibility.md. Will it still work?

Almost certainly, if it runs a reasonably standard AOSP-based ROM. The installer scans multiple known boot-animation paths (`/system/media/`, `/product/media/`, `/system/product/media/`, `/vendor/media/`, `/system_ext/media/`, `/odm/media/`) rather than assuming one fixed location, which covers the vast majority of OEM layouts. If it genuinely fails, please open an issue with your device model and ROM.

## Can I use a dark-mode boot animation?

Yes. Place it as `bootanimation-dark.zip` in `module/assets/` and set `dark_animation: true` in `metadata.yml`. The installer will apply it alongside the standard animation where the ROM supports dark-mode boot animations.

## Can I replace the shutdown animation too?

Yes, using `shutdownanimation.zip` / `shutdownanimation-dark.zip` and the corresponding `shutdown_animation: true` flag in `metadata.yml`.

## Will this conflict with other boot animation modules?

The installer checks for other active boot-animation modules before installing and will prompt to disable them safely rather than installing on top of a conflicting module.

## How do I preview my animation before flashing?

Run `tools/preview.sh` on a connected, rooted device. It bind-mounts your animation over the live path temporarily, without modifying any partition permanently, and without requiring a reboot.

## What causes a bootloop after installing a boot animation module?

Almost always a malformed `bootanimation.zip` — wrong compression method, missing `desc.txt`, or a corrupted PNG sequence — rather than the installer itself, since the installer validates the ZIP before touching the system partition. Run `tools/validate.sh` first; see [`docs/Troubleshooting.md`](docs/Troubleshooting.md) for recovery steps if it already happened.

## Can I contribute an animation to the main collection?

This repository is the *template*. If you're looking for the curated animation library, see the companion `bootanimations` repository under the same organization.

## What license is this under?

MIT. See [`LICENSE`](LICENSE).
