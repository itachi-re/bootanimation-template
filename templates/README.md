# templates/

Starter files for building a **new** animation from scratch, as opposed to porting an existing one (see `docs/Porting.md` for that).

## Usage

1. Copy `desc.txt` into your working frames directory and adjust `width`, `height`, and `fps` to your target device (see `docs/Compatibility.md` for common resolutions).
2. Create `part0/` and `part1/` folders (or as many parts as your `desc.txt` references) and fill them with sequential, zero-padded PNG frames (`00000.png`, `00001.png`, ...).
3. Pack with `tools/pack.sh <your_frames_dir> module/assets/bootanimation.zip`.
4. Validate with `tools/validate.sh module/assets/bootanimation.zip`.

`part0/.gitkeep` is included only so the empty starter folder is tracked by git — delete it once you add real frames.

Full syntax reference: [`docs/Creating.md`](../docs/Creating.md#desctxt-syntax).
