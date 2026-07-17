# Credits

## Maintainer

**itachi_re** — [github.com/itachi-re](https://github.com/itachi-re)

## References and inspiration

- AOSP `frameworks/base/cmds/bootanimation` — the reference implementation of `desc.txt` parsing and playback that all documentation in this repository is based on.
- The Magisk project and its module developer guides, which shaped the `customize.sh`-first installer approach used here (avoiding legacy `update-binary` logic in favor of the modern installer flow).
- The KernelSU and APatch projects, for documenting their respective module directory conventions (`/data/adb/ksu/modules/`, `/data/adb/ap/modules/`).
- The broader Magisk-module-development community, whose scattered forum posts and module source code were cross-referenced to build the OEM path-compatibility list in [`Compatibility.md`](Compatibility.md).

## License acknowledgment

This project is released under the MIT License. It does not bundle or redistribute any third-party boot animation content — only the installer/template tooling. Any example animation included under `examples/` is provided solely to demonstrate the expected file structure and is licensed separately as noted in that directory.
