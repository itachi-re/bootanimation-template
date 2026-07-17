# Packaging & Release Process

## Local build

```bash
./tools/validate.sh module/assets/bootanimation.zip
./tools/build.sh
```

`build.sh` assembles the module ZIP from:

- `module.prop`, `customize.sh`, `uninstall.sh`, `service.sh`, `post-fs-data.sh`, `system.prop`
- `META-INF/` (installer entry points)
- `module/assets/bootanimation.zip` (and dark/shutdown variants if present)

Output lands in `dist/<module-id>-<version>.zip`.

## Manual release

```bash
./tools/release.sh --version v1.0.0
```

This tags the commit, builds the module ZIP, and creates a GitHub Release with the ZIP attached, using the changelog entry under that version heading in `CHANGELOG.md` as the release body.

## Automated release (recommended)

Pushing a tag matching `v*.*.*` triggers `.github/workflows/release.yml`, which:

1. Runs the full validation suite (ShellCheck, ZIP validation, `desc.txt` validation, metadata schema check).
2. Builds the module ZIP via `tools/build.sh`.
3. Uploads the ZIP as a build artifact.
4. Creates a GitHub Release with the ZIP attached and changelog notes.

If any validation step fails, the release is not created — this keeps every published release guaranteed-installable.

## Versioning

Follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

- **MAJOR** — breaking installer changes (e.g. dropped root-manager support)
- **MINOR** — new animation, new feature (e.g. added dark-mode support)
- **PATCH** — bug fixes, documentation, validator improvements

`module.prop`'s `version` and `versionCode` should be updated in the same commit as the tag.

## Checklist before tagging a release

- [ ] `tools/validate.sh` passes with no warnings
- [ ] `tools/preview.sh` tested on at least one physical or virtual device
- [ ] `metadata.yml` reflects the correct supported Android versions
- [ ] `CHANGELOG.md` has an entry for the new version
- [ ] `module.prop` version/versionCode bumped
