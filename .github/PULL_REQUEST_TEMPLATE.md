## What changed

<!-- Describe the change and why it's needed -->

## Type of change

- [ ] Bug fix
- [ ] New feature/tool
- [ ] Documentation
- [ ] CI/workflow
- [ ] Other (describe above)

## Checklist

- [ ] `shellcheck` passes on any shell scripts touched
- [ ] Installer-context scripts (`customize.sh`, `service.sh`, `post-fs-data.sh`, `uninstall.sh`) remain BusyBox `ash`-compatible (checked with `dash -n`)
- [ ] `tools/validate.sh` passes against relevant test fixtures, if applicable
- [ ] Documentation updated if behavior changed
- [ ] Tested on at least one real device or emulator, if the change touches installer behavior

## Related issue

Closes #
