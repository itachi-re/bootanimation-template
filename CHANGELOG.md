# Changelog

All notable changes to this template are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Nothing yet.

## [1.0.0] - 2026-07-17

### Added

- Initial release of `bootanimation-template`.
- Root-manager-agnostic `customize.sh` supporting Magisk, KernelSU, and APatch.
- Automatic boot-animation path detection across 7 OEM partition layouts.
- Conflict detection and safe disabling of competing boot-animation modules, with automatic re-enable on uninstall.
- `tools/validate.sh`, `tools/pack.sh`, `tools/extract.sh`, `tools/preview.sh`, `tools/build.sh`.
- On-device diagnostics: `tools/check_bootanimation.sh`, `tools/check_boot_m.sh`.
- Full documentation set: Installation, Compatibility, Creating, Packaging, Troubleshooting, Porting, Credits.
- `metadata.yml` schema for fork metadata.

[Unreleased]: https://github.com/itachi-re/bootanimation-template/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/itachi-re/bootanimation-template/releases/tag/v1.0.0
