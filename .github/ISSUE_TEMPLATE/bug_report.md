---
name: Bug report
about: Something isn't working as expected
title: "[Bug] "
labels: bug
assignees: ''
---

**Describe the bug**
A clear description of what went wrong.

**Environment**
- Root manager (Magisk/KernelSU/APatch) and version:
- Android version and API level:
- Device model:
- ROM (AOSP/LineageOS/OneUI/HyperOS/etc.) and build:

**Steps to reproduce**
1.
2.
3.

**Expected behavior**
What you expected to happen instead.

**Diagnostic output**
Please attach the output of:
```
adb shell su -c "sh /path/to/tools/check_bootanimation.sh"
```
and, if the issue is path-related:
```
adb shell su -c "sh /path/to/tools/check_boot_m.sh"
```

**Additional context**
Anything else relevant (screenshots, logcat excerpts, etc.).
