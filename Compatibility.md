# Compatibility

## Android versions

| Version | API level | Status |
|---|---|---|
| Android 8 (Oreo) | 26–27 | ✅ Supported |
| Android 9 (Pie) | 28 | ✅ Supported |
| Android 10 | 29 | ✅ Supported |
| Android 11 | 30 | ✅ Supported |
| Android 12 / 12L | 31–32 | ✅ Supported |
| Android 13 | 33 | ✅ Supported |
| Android 14 | 34 | ✅ Supported |
| Android 15 | 35 | ✅ Supported |
| Android 16 | 36 | ✅ Supported |

## Root managers

| Manager | Install method detected via | Notes |
|---|---|---|
| Magisk | `MAGISK_VER_CODE` env / `magisk -v` | Uses modern installer flow; no legacy `update-binary` logic |
| KernelSU | `ksud` binary presence | Module lands under `/data/adb/ksu/modules/` |
| APatch | `apd` binary presence | Module lands under `/data/adb/ap/modules/` |

The installer detects the active manager at runtime — you do not need separate builds per manager.

## Boot-animation partition layout by ROM family

Different ROMs place `bootanimation.zip` in different locations. The installer probes all of the following, in order, and uses the first writable match:

| Path | Typically used by |
|---|---|
| `/system/media/` | AOSP, LineageOS, Evolution X, crDroid, PixelOS |
| `/product/media/` | Newer AOSP-based ROMs with a separate `product` partition |
| `/system/product/media/` | Devices with `product` merged under `system` |
| `/vendor/media/` | Some OEM builds (vendor-owned boot animation) |
| `/system_ext/media/` | Devices with a `system_ext` partition |
| `/odm/media/` | ODM-customized devices |

### OEM-specific notes

| OEM / Skin | Notes |
|---|---|
| Samsung OneUI | Boot animation path may be under `/system_ext/media/` on newer One UI builds; shutdown animation support varies by region firmware |
| Xiaomi HyperOS / MIUI | May ship animations pre-compiled with a different container format on some regions — validated by `tools/validate.sh` before install |
| OPPO/OnePlus ColorOS / OxygenOS | Frequently uses `/my_product/media/` in addition to standard paths on unified-OS builds |
| Nothing OS | Standard AOSP layout, no special handling required |
| ASUS ROG | Standard layout; some builds restrict `/vendor` write access — installer falls back to `/system` paths |

If your device uses a path not listed here, please open an issue with the output of `tools/check_boot_m.sh` from your device.
