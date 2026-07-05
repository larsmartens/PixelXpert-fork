# Android 17 Recovery Outcome - 2026-07-05

Device: Pixel 7 Pro `cheetah` on Android 17 `CP2A.260605.012`, SDK 37.

## Facts

- PixelXpert is installed as a normal data app, not as a mounted `/system/priv-app`.
- PixelXpert's KSU module remains disabled and has `skip_mount` present.
- LSPosed is enabled, but the LSPosed DB has only PixelXpert enabled.
- PixelXpert LSPosed scopes are limited to:
  - `sh.siava.pixelxpert`
  - `com.android.systemui`
- No LSPosed `system` scope rows are present.
- PixelXpert launched successfully after multiple reboots with LSPosed active.
- No new `system_server_*` dropbox entries or tombstones appeared after the PixelXpert-only LSPosed activation or after the restored-module reboot.
- Recent non-foreground app/service crash entries appeared for `flix.com.vision` and `com.qorvo.uwb.vendorservice`. These did not coincide with `system_server` PID resets or new `system_server_*` dropbox entries.
- Play Integrity is back to STRONG in `gr.nikolasspyr.integritycheck` after a fresh check:
  - `MEETS_BASIC_INTEGRITY`
  - `MEETS_DEVICE_INTEGRITY`
  - `MEETS_STRONG_INTEGRITY`
- The effective Play Integrity change was enabling `spoofVendingFinger=1` in PIFork while keeping `spoofVendingSdk=0`.
- TEESimulator targets were restored to include GMS, GSF, Play Store, both checker packages, and Key Attestation.
- TEESimulator `security_patch.txt` is set to `all=2026-06-05`.
- Zygisk Next v1.4.2, PIFork v17, and TEESimulator-RS v6.0.1-282 are current upstream releases.
- KSU-Next Manager remains v3.2.0/33129 to match the blu_spark r266 kernel-side KSU version 33129. KSU-Next v3.3.0/33214 exists but is not aligned with the current kernel path.

## Restored Module State

Enabled after the final restore reboot:

- `ViPER4Android-RE-Fork` v8.0
- `adguardcert` v2.2.0-beta.7
- `magisk-tailscaled` v2.0.0.1
- `rclone` v1.74.3
- `rvmm-zygisk-mount` v9
- `unlimitedphotos` v3
- `zygisk-detach` v1.23.1
- `zygisk_nohello` v0.0.7
- `zygisk_lsposed` v2.1.0
- `zygisksu` v1.4.2
- `playintegrityfix` v17
- `tricky_store` / TEESimulator-RS v6.0.1-282

Intentionally still disabled:

- `PixelXpert`: disabled as a KSU mounted module; active as a data app plus LSPosed.
- `rezygisk`: conflicts with the selected Zygisk Next path.
- `zygisk_thanox`: deferred by request.
- `magisk-captive-manager`: already disabled before the session.
- `youtube-morphe-jhc`: module description says to keep disabled because RVMM handles mounting. It was not updated because `/data` had less than 1 GB free and a safe full rollback copy would have been too large.

## Hypotheses

- The original PixelXpert boot stalls were caused by boot-sensitive package/priv-app mount and broad LSPosed startup behavior, not by PixelXpert's data-app UI or a narrow SystemUI scope.
- Android 17 Play Integrity was failing A13+ device recognition because Play Store's eligibility path was still seeing the live CP2A ROM fingerprint. Enabling `spoofVendingFinger=1` made Play Store consume the PIFork Canary fingerprint path.
- Henrik's checker did not reliably refresh after the final reboot because the app rotated and taps missed the request button; Nikolasspyr's checker provided the final fresh STRONG verdict.

## Open Items

- PixelXpert is validated for self and SystemUI scopes only. Launcher, Dialer, Phone, Settings, and other feature-specific scopes remain staged work.
- YouTube Morphe remains at versionCode `20221061`; latest known release is `20221064`. Update later when enough free space is available for a safe rollback.
- Thanox remains deferred.
- KSU-Next kernel/userspace should not be moved to v3.3.0 unless a matching stable Pixel 7 Pro kernel path is selected.
- `flix.com.vision` and `com.qorvo.uwb.vendorservice` produced app/service crash entries after the module restore. They should be treated separately from the PixelXpert/system_server watchdog issue.

## Rollback

- Disable LSPosed and restore the pre-sanitized DB:
  `/data/adb/pixelxpert-stage/lsposed-pixelxpert-only-20260705-162256/rollback-disable-lsposed-restore-db.sh`
- Restore PIFork `custom.pif.prop` before `spoofVendingFinger=1`:
  `/data/adb/pixelxpert-stage/pif-spoof-vending-fingerprint-20260705-163124/rollback-restore-pif-custom-prop.sh`
- Restore selected module disable state and the previous Unlimited Photos module:
  `/data/adb/pixelxpert-stage/restore-session-modules-20260705-164402/rollback-disable-restored-modules.sh`

Raw device captures remain local under `docs/android-17/evidence/play-integrity-20260705-1610/` and should be reviewed/redacted before committing wholesale.
