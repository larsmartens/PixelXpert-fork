# Android 17 Module And Integrity Validation - 2026-07-06

Device: Pixel 7 Pro `cheetah`, Android 17 `CP2A.260605.012`, SDK 37.

This note records the sanitized post-reboot validation after installing the GitHub Actions PixelXpert artifact from commit `e2fd73aa` and moving Play Integrity back to the updated KOWX/TrickyStore stack. Raw captures from this session include app UI state and should remain uncommitted unless separately reviewed and redacted.

## Current Result

- PixelXpert is installed as a normal data app and is enabled in LSPosed with six non-`system_server` scopes.
- PixelXpert's KSU module is enabled only as a helper/module payload; `skip_mount` is present, so `/system/priv-app/PixelXpert` is not mounted into Android package scanning.
- Hybrid Mount Lite is enabled as module id `hybrid_mount`, version `4.2.0-1815`.
- AdGuard certificate, Unlimited Photos, and rclone are configured with Hybrid Mount `magic` markers.
- Play Integrity is no longer `NO_INTEGRITY`; the fresh SPIC request at `2026-07-06 03:59:06 +0200` returned `MEETS_DEVICE_INTEGRITY`, `PLAY_RECOGNIZED`, and `LICENSED`. Strong integrity is still not restored.
- No fresh `system_server_*` dropbox entry or tombstone appeared after the latest reboot and validation window. The newest tombstones remained from `2026-07-06 01:21`.

## PixelXpert

Installed APK:

- package: `sh.siava.pixelxpert`
- version: `canary-513`
- app APK SHA256: `44d33099a0c2769b0a02947c09ab6327e9bf8dd4b0b03ff1c3553975a148b4df`
- module APK SHA256: `44d33099a0c2769b0a02947c09ab6327e9bf8dd4b0b03ff1c3553975a148b4df`

Evidence:

- PixelXpert, Settings, Google Dialer, Google Photos, AdGuard, and SPIC all launched through Android launcher intents.
- LSPosed loaded PixelXpert `canary-513` in PixelXpert, Dialer, Settings, and SystemUI.
- LSPosed reported `PixelXpert Records: 187` in PixelXpert, Dialer, Settings, and SystemUI.
- The previous `GestureNavbarManager` / `BackPanelController` hook failure did not recur after commit `e2fd73aa`.
- One remaining Android 17 compatibility warning exists: `preference provider probe timed out in com.google.android.apps.nexuslauncher`. This did not crash Launcher or SystemUI during this validation.

GitHub Actions:

- run: `28762246613`
- result: success
- artifact: `PixelXpert.zip`
- artifact SHA256: `7b3657fee1c32c29c2586fd3df8ae2ca442ae4d32fdff4ee0eece31a3dd9dfca`
- jobs passed: static module guards, assembleDebug, assembleRelease, lint, dependency validation, zip integrity

Rollback:

- APK reinstall rollback:
  `/data/adb/pixelxpert-stage/install-ci-patched-apk-full-reinstall-20260706-034618/rollback.sh /data/adb/pixelxpert-stage/install-ci-patched-apk-full-reinstall-20260706-034618`
- LSPosed scope rollback:
  `/data/adb/pixelxpert-stage/lsposed-pixelxpert-scopes-e2fd73aa-20260706-0350/rollback.sh /data/adb/pixelxpert-stage/lsposed-pixelxpert-scopes-e2fd73aa-20260706-0350`

## Module State

Enabled:

- `PixelXpert` `canary-513`, `skip_mount=1`
- `hybrid_mount` `4.2.0-1815`
- `adguardcert` `v2.2.0-beta.7`, Hybrid magic marker present
- `unlimitedphotos` `v3`, Hybrid magic marker present
- `rclone` `v1.16`, Hybrid magic marker present
- `ViPER4Android-RE-Fork` `8.0`
- `magisk-tailscaled` `v2.0.0.1`, process `tailscaled` running
- `rvmm-zygisk-mount` `v9`
- `zygisksu` `1.4.2`
- `zygisk_lsposed` `v2.1.0`
- `zygisk_nohello` `v0.0.7`
- `zygisk-detach` `v1.23.1`
- `playintegrityfix` `v4.6-inject-s`
- `tricky_store` `v1.4.1 (245-72b2e84-release)`
- `TA_utl`

Disabled:

- `magisk-captive-manager`
- `youtube-morphe-jhc`
- `zygisk_thanox`

## Hybrid Mount

Hybrid Mount is active again under id `hybrid_mount`. The current blacklist contains only:

- `AAaTempSpoof`
- `scene_swap_controller`

Observed behavior:

- Unlimited Photos is mounted successfully through Hybrid magic. `/system/etc/sysconfig/pixel_2016_exclusive.xml` exists and includes the expected `NEXUS_PRELOAD` Photos feature.
- rclone binaries are mounted at `/vendor/bin/rclone`, `/system/vendor/bin/rclone`, `/vendor/bin/rclone-mount`, and `/system/vendor/bin/rclone-mount`. No rclone remote is configured yet because `/data/adb/modules/rclone/conf/rclone.conf` is absent.
- AdGuard certificate paths are mounted into `/system/etc/security/cacerts` and Conscrypt APEX cacert paths.
- PixelXpert is protected from priv-app boot scanning by `skip_mount`.

## AdGuard And In-App Filtering

AdGuard app:

- package: `com.adguard.android`
- version: `4.14.46`
- process running during validation

Certificate module:

- `/system/etc/security/cacerts/0f4ed297.0` present
- `/apex/com.android.conscrypt/cacerts/0f4ed297.0` present
- `/apex/com.android.conscrypt@371735480/cacerts/0f4ed297.0` present

Assessment:

- The Android 17 system/APEX CA side is working for apps that use the platform trust store.
- In-app HTTPS filtering should be controlled through AdGuard's own per-app management UI: enable route traffic, content filtering, and HTTPS filtering only for selected apps.
- Some apps will still resist filtering because of certificate pinning, custom trust managers, native TLS stacks, root checks, QUIC/HTTP3, or app-specific proxy/VPN bypass behavior.
- Do not enable a global TLS-unpinning LSPosed or Frida-style module by default. If a specific app must be filtered and still fails with AdGuard per-app HTTPS filtering enabled, test that app separately with a reversible per-app exception/unpinning plan.

## Play Integrity

Current stack:

- Zygisk Next `1.4.2`
- LSPosed `2.1.0`
- KOWX Play Integrity Fix `v4.6-inject-s`
- official TrickyStore `v1.4.1 (245-72b2e84-release)`
- KOWX Tricky Addon `v4.4`
- NoHello remains enabled, but the restored Device verdict does not prove NoHello is required.

Targeting:

- TrickyStore target/config files are present.
- Keybox contents were not printed or committed.

Fresh SPIC result:

- timestamp: `2026-07-06 03:59:06 +0200`
- device verdict: `MEETS_DEVICE_INTEGRITY`
- app verdict: `PLAY_RECOGNIZED`
- licensing verdict: `LICENSED`
- missing: `MEETS_STRONG_INTEGRITY`

Assessment:

- The "at least the level below strong" goal is currently met.
- Strong is still blocked. After testing the current updated stack and target-list variants, the remaining likely blockers are active keybox/source validity, server-side revocation/classification, Android 17 attestation behavior, or Google account/session state.
- Further Strong work should focus on validating or replacing the attestation source without exposing key material, not on PixelXpert, Hybrid Mount, or AdGuard certificate state.

Rollback:

- Minimal target-list rollback:
  `/data/adb/pixelxpert-stage/pi-minimal-targets-20260706-0345/rollback.sh /data/adb/pixelxpert-stage/pi-minimal-targets-20260706-0345`
- No-`gms!` target-list rollback:
  `/data/adb/pixelxpert-stage/pi-no-gms-bang-targets-20260706-0347/rollback.sh /data/adb/pixelxpert-stage/pi-no-gms-bang-targets-20260706-0347`
- Clean KOWX stack rollback:
  `/data/adb/pixelxpert-stage/pi-clean-kowx-stack-20260706-0352/rollback.sh /data/adb/pixelxpert-stage/pi-clean-kowx-stack-20260706-0352`

## V4A

ViPER4Android RE Fork app launches and its module is enabled, but the audio effect is not live:

- `libv4a_re.so` is missing from `/vendor/lib*/soundfx` and `/system/vendor/lib*/soundfx`.
- `audio_effects.xml` files do not contain V4A entries.

The current module modifies audio effect configuration at runtime in a way that is not safely taking effect on this Android 17/KSU/Hybrid stack. A patched payload or a different current V4A module is still needed. The present state is app-installed/module-enabled, but not functional audio processing.

## KSU-Next

Current live root:

- `ksud 3.2.0`
- KSU-Next Manager `v3.2.0`, versionCode `33129`
- blu_spark r266 remains the selected kernel path from the prior validation.

KSU-Next `v3.3.0` exists upstream, but this device was deliberately returned to `3.2.0` because the current blu_spark r266 kernel-side KSU reports `33129`. Do not install a newer manager alone unless the kernel/userspace UAPI is upgraded together.
