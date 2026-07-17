<div align="center">

# 🎬 bootanimation-template

**A production-ready, root-manager-agnostic template for building Android Boot Animation packages.**

Replace one ZIP. Push a tag. Ship a release.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Magisk](https://img.shields.io/badge/Magisk-supported-brightgreen)
![KernelSU](https://img.shields.io/badge/KernelSU-supported-brightgreen)
![APatch](https://img.shields.io/badge/APatch-supported-brightgreen)
![ShellCheck](https://img.shields.io/badge/shellcheck-clean-success)

[Quick Start](#-quick-start) • [Features](#-features) • [Docs](#-documentation) • [Contributing](#-contributing)

</div>

---

## 📖 About

Most boot-animation repositories on GitHub are one of two things: a bare ZIP file with no installer, or a single-purpose Magisk module that breaks the moment someone runs KernelSU or APatch instead. `bootanimation-template` exists to fix that.

This repository is a **template**, not a boot animation itself. Fork it, drop your `bootanimation.zip` into `module/assets/`, fill in `module/metadata.yml`, and you have a fully working, installable module — validated, previewable, and CI-tested — without writing a single line of shell script yourself.

## ✨ Features

| Feature | Description |
|---|---|
| 🔌 **Root-manager agnostic** | Installs cleanly under Magisk, KernelSU, and APatch with no manual edits |
| 📍 **Universal path detection** | Automatically finds the correct boot animation partition/mount across OEM layouts |
| ✅ **Automatic validation** | Checks ZIP structure, `desc.txt`, PNG sequences, FPS, and resolution before install |
| 👁 **Safe preview mode** | Preview an animation via a temporary bind mount — no reboot required |
| 🧠 **Environment detection** | Detects Android version, API level, architecture, BusyBox, and conflicting modules |
| 🛡 **Conflict handling** | Detects and safely disables competing boot-animation modules |
| 🤖 **Full CI/CD** | ShellCheck, Markdown lint, YAML lint, ZIP validation, and automatic GitHub Releases |
| 📚 **Deep documentation** | Covers boot animation internals most repos never explain |

## 📱 Compatibility

**Android versions:** 8 · 9 · 10 · 11 · 12 · 13 · 14 · 15 · 16

**Root managers:**

| Manager | Status |
|---|---|
| Magisk | ✅ Fully supported |
| KernelSU | ✅ Fully supported |
| APatch | ✅ Fully supported |

**Tested ROM families:** AOSP, PixelOS, LineageOS, Evolution X, crDroid, OneUI, HyperOS, MIUI, ColorOS, OxygenOS, NothingOS, RealmeUI, and other AOSP derivatives. See [`docs/Compatibility.md`](docs/Compatibility.md) for partition-layout notes per ROM.

## 📂 Repository Structure

```
bootanimation-template/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── ROADMAP.md
├── FAQ.md
├── docs/
├── tools/
│   ├── build.sh
│   ├── validate.sh
│   ├── pack.sh
│   ├── extract.sh
│   ├── preview.sh
│   ├── check_bootanimation.sh
│   └── check_boot_m.sh
├── templates/                  # starter desc.txt + part0/ for new animations
├── examples/
├── tests/
├── screenshots/
├── preview/
├── .github/
└── module/                     # ← the actual flashable payload
    ├── module.prop
    ├── system.prop
    ├── customize.sh
    ├── service.sh
    ├── post-fs-data.sh
    ├── uninstall.sh
    ├── metadata.yml             # ← fill this in
    ├── META-INF/com/google/android/
    │   ├── update-binary
    │   └── updater-script
    └── assets/
        └── bootanimation.zip    # ← replace this
```

`module/` is packaged as-is by `tools/build.sh` into the flashable ZIP — everything outside it (docs, CI, dev tooling) stays out of what actually gets flashed to a device.

## 🚀 Quick Start

1. **Fork** this repository.
2. Replace `module/assets/bootanimation.zip` with your own animation.
3. Edit `module/metadata.yml` with your animation's name, author, and supported Android versions.
4. Edit `module/module.prop` with your module's `id`, `name`, `version`, and `author`.
5. Run the validator locally:
   ```bash
   ./tools/validate.sh module/assets/bootanimation.zip
   ```
6. Preview it on a connected device without rebooting:
   ```bash
   ./tools/preview.sh
   ```
7. Push a tag (`v1.0.0`) — GitHub Actions builds and publishes the release ZIP automatically.

Full walkthrough: [`docs/Installation.md`](docs/Installation.md) and [`docs/Creating.md`](docs/Creating.md).

## 🔨 Building & Packaging

`tools/build.sh` assembles the final flashable/module ZIP from `module/assets/`, `module/module.prop`, and the installer scripts, then hands off to `tools/release.sh` for GitHub Release packaging. See [`docs/Packaging.md`](docs/Packaging.md) for the full pipeline and manual steps.

## 👁 Previewing

`tools/preview.sh` temporarily bind-mounts your animation over the live boot animation path, starts the `bootanim` service, waits a configurable duration, then restores the original mounts — all without a reboot. Details and safety notes: [`docs/Creating.md`](docs/Creating.md#previewing-safely).

## 🧪 Testing

`tests/` contains fixture ZIPs (valid and intentionally broken) used by `tools/validate.sh` and the CI ZIP-validation workflow to catch regressions in the validator itself.

## 🖼 Screenshots

Add device screenshots and animation previews to `screenshots/` and `preview/`. See [`docs/Creating.md`](docs/Creating.md#previews-and-screenshots) for recommended formats (`.webp` for previews, `.gif` for quick looks).

## ❓ FAQ & Troubleshooting

Common issues (bootloops, black screen, animation not applying, module conflicts) are covered in [`FAQ.md`](FAQ.md) and [`docs/Troubleshooting.md`](docs/Troubleshooting.md).

## 🗺 Roadmap

See [`ROADMAP.md`](ROADMAP.md).

## 🤝 Contributing

Contributions are welcome — new animations, tooling improvements, documentation fixes. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) and our [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) before opening a PR.

## 🙏 Credits

See [`docs/Credits.md`](docs/Credits.md) for upstream references and inspiration.

## 📄 License

Released under the [MIT License](LICENSE).

---

<div align="center">

Maintained by **[itachi_re](https://github.com/itachi-re)**

</div>
