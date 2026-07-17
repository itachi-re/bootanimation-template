# Contributing

Thanks for considering a contribution to `bootanimation-template`. This document covers the workflow for both code/tooling contributions and animation-related contributions.

## Before you start

- For anything beyond a small fix, open an issue first describing what you want to change — this avoids wasted work if the direction doesn't fit the project.
- This repository is the **template/installer**, not the animation collection. If you want to contribute a new boot animation for others to use, that belongs in the companion `bootanimations` repository, not here.

## Development setup

You'll need:

- `bash`, `zip`/`unzip`
- `shellcheck` (for linting installer/tool scripts)
- `adb` (only needed for `tools/preview.sh` and on-device diagnostics)
- A rooted test device or emulator running Magisk, KernelSU, or APatch, for end-to-end testing

## Making changes

### Shell scripts

- Installer-context scripts (`customize.sh`, `service.sh`, `post-fs-data.sh`, `uninstall.sh`) **must** stay BusyBox `ash`/`dash`-compatible — no bashisms (`[[`, arrays, `local` is fine but avoid process substitution, `<()`, etc.). Test with `dash -n script.sh` at minimum.
- Host-side dev tools (`tools/*.sh`, except the two `check_*.sh` device scripts) may use bash features freely, since they run on a development machine, not on-device.
- Run `shellcheck` on any script you touch before opening a PR:

  ```bash
  shellcheck customize.sh service.sh post-fs-data.sh uninstall.sh
  shellcheck tools/*.sh
  ```

- Quote every variable expansion. Avoid hardcoded paths — add new candidate paths to the shared `BOOTANIM_CANDIDATES` list in `customize.sh` rather than special-casing a device.

### Documentation

- Keep `docs/` files scoped — if you're adding a large new topic, consider whether it deserves its own file rather than growing an existing one indefinitely.
- Update `README.md`'s relevant section if you add a new tool or workflow.

### Tests

- Add fixture ZIPs (valid and deliberately broken) to `tests/` when fixing a validator bug, so the regression is caught automatically by CI in the future.

## Commit style

Use clear, imperative commit messages (`Add HyperOS unwrap support to extract.sh`, not `fixed stuff`). Reference the related issue number where applicable.

## Pull requests

1. Fork and branch from `main`.
2. Make your change, keeping it focused — unrelated changes should be separate PRs.
3. Ensure `shellcheck`, markdown lint, and (if applicable) `tools/validate.sh` against any test fixtures all pass locally; CI will re-run these regardless.
4. Open the PR with a description of *what* changed and *why*.
5. Be responsive to review feedback — PRs that go stale without updates may be closed and can be reopened later.

## Code of Conduct

Participation in this project is governed by our [Code of Conduct](CODE_OF_CONDUCT.md).
