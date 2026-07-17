# Security Policy

## Scope

This project is an installer/template for Android boot animation modules, running with root privileges via Magisk, KernelSU, or APatch. Security issues of interest include:

- Installer scripts that could be tricked into writing outside the intended module/target path
- Privilege-related issues in `customize.sh`, `service.sh`, `post-fs-data.sh`, or `uninstall.sh`
- `tools/preview.sh` failing to restore the original boot animation state on failure, leaving a device in a broken boot state
- Supply-chain issues in `.github/workflows/` (e.g. an action pinned to a mutable tag rather than a commit SHA)

Cosmetic issues, or bugs in a specific fork's own `module/assets/bootanimation.zip` content, are **not** in scope for this repository — report those to the fork's maintainer.

## Reporting a vulnerability

Please do **not** open a public issue for security vulnerabilities. Instead, email:

**xanbenson99@gmail.com**

Include:

- A description of the issue and its potential impact
- Steps to reproduce, if applicable
- Affected root manager(s) and Android version(s), if relevant

You should receive an acknowledgment within a few days. Once a fix is available, a coordinated disclosure timeline will be agreed on before any public write-up.

## Supported versions

Only the latest tagged release receives security fixes. Forks are responsible for pulling upstream security fixes into their own release history.
