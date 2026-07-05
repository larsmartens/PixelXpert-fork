# Android 17 Module Mount Isolation

Date: 2026-07-05
Device: Pixel 7 Pro, Android 17 CP2A.260605.012, SDK 37, blu_spark KSU-Next.

## Findings

- PixelXpert is boot-safe when installed as a normal data app and kept in KSU `skip_mount` mode.
- PixelXpert's mounted `/system/priv-app` path is not required for the app to install or for LSPosed to load the module.
- PixelXpert hooks were globally disabled by `persist.pixelxpert.disable_hooks=1`; clearing that property activates LSPosed-loaded hooks.
- Removing `android` from PixelXpert LSPosed scope and keeping `persist.pixelxpert.a17.unsafe_scopes=0` avoids the boot-sensitive system_server/framework path.
- With hooks enabled, LSPosed loaded PixelXpert in `com.android.systemui`, `com.google.android.apps.nexuslauncher`, `com.android.settings`, `com.google.android.dialer`, and `sh.siava.pixelxpert`.
- The live canary showed Android 17 SystemUI hook failures:
  - `ScreenGestures` and `StatusbarGestures` constructed `GestureDetector` from the deferred hook-loading worker thread.
  - `KeyguardMods` assumed `mComposeKGMiddleCustomTextView` existed before the Android 17 keyguard constraint hook ran.
- Hybrid Mount Lite v4.2.0 provider-only and single-module AdGuard cert tests booted. AdGuard cert also works without Hybrid Mount.
- Hybrid Mount Nano v4.2.0 provider-only booted but `hybrid-mount` produced a native SIGSEGV tombstone, so Nano is not a safe candidate on this stack.
- V4A, rclone, and unlimitedphotos need separate module-specific work: their expected live system-tree targets were absent when Hybrid Mount was disabled.
- `com.qorvo.uwb.vendorservice` repeatedly crashed because Android reported no `nfc` service. It was temporarily disabled for user 0 to stop UI crash dialogs while testing PixelXpert.
- The patched PixelXpert Canary CI APK from GitHub Actions run `28756237299` installed successfully only after a full package reinstall. A plain `pm install -r` and `pm uninstall -k --user 0` path both preserved incompatible package signature state.
- After full reinstall, PixelXpert's package UID changed from `10359` to `10417`. The device-protected PixelXpert preferences file was restored with the new app UID.
- LSPosed kept PixelXpert's old data-app `base.apk` path after reinstall. The LSPosed `modules_config.db` row for `sh.siava.pixelxpert` was updated to the new `/data/app/.../base.apk` path, and the unsafe `android` scope row was removed again.

## Current Device State After Isolation

- `sys.boot_completed=1`
- PixelXpert KSU module enabled with `skip_mount=1`
- PixelXpert live data APK hash after CI install: `17f97b0fcb86697a0e5f0a133fbd10dc36006997d4a85ebd3c38ee7339a65214`
- PixelXpert module APK hash after CI install: `17f97b0fcb86697a0e5f0a133fbd10dc36006997d4a85ebd3c38ee7339a65214`
- PixelXpert hooks enabled: `persist.pixelxpert.disable_hooks=0`
- Android 17 unsafe hooks disabled: `persist.pixelxpert.a17.unsafe_scopes=0`
- PixelXpert LSPosed scope excludes `android`
- Hybrid Mount disabled
- AdGuard cert and tailscaled enabled
- V4A, rclone, unlimitedphotos, Thanox disabled pending isolated fixes
- Qorvo UWB vendor service disabled for user 0; rollback is available on-device
- Last completed validation before USB transport disappeared: the phone booted after the LSPosed DB path fix, unlocked once, and survived a 75 second post-unlock idle window. The final LSPosed log/dropbox collection after that reboot did not complete because adb and fastboot both lost the device and Windows no longer showed a Pixel/Google/ADB USB interface.

## Rollback Commands

- Restore PixelXpert hook kill switch and LSPosed DB:
  `/data/adb/pixelxpert-stage/pixelxpert-hooks-nonsystemserver-20260705-234625/rollback.sh /data/adb/pixelxpert-stage/pixelxpert-hooks-nonsystemserver-20260705-234625`
- Re-enable Qorvo UWB vendor service:
  `/data/adb/pixelxpert-stage/disable-qorvo-uwb-20260705-234910/rollback.sh`
- Restore safe module baseline markers:
  `/data/adb/pixelxpert-stage/safe-module-baseline-20260705-233846/rollback.sh /data/adb/pixelxpert-stage/safe-module-baseline-20260705-233846`
- Restore pre-CI PixelXpert APK after full reinstall:
  `/data/adb/pixelxpert-stage/install-ci-patched-apk-full-reinstall-20260706-000823/rollback.sh /data/adb/pixelxpert-stage/install-ci-patched-apk-full-reinstall-20260706-000823`
- Restore pre-path-fix LSPosed DB:
  `/data/adb/pixelxpert-stage/lsposed-pixelxpert-db-20260706-001540/rollback.sh /data/adb/pixelxpert-stage/lsposed-pixelxpert-db-20260706-001540`

## Code Fixes Added

- `ScreenGestures`: construct the lockscreen double-tap detector with `Handler(Looper.getMainLooper())`.
- `StatusbarGestures`: construct pull-down and pull-up gesture detectors with `Handler(Looper.getMainLooper())`.
- `KeyguardMods`: skip the Android 17 keyguard constraint hook until the custom text view and placeholder ID are available.

## Reconnect Checklist

1. Do not enter the SIM PIN unless Android explicitly shows a SIM PIN request.
2. Reconnect USB or power the phone if it is off, then check `adb devices -l` and `fastboot devices`.
3. If Android is booted, verify `sys.boot_completed`, `init.svc.bootanim`, and root with `su -c id`.
4. Pull LSPosed module logs and dropbox entries after the LSPosed DB path fix.
5. Confirm `modules_config.db` points `sh.siava.pixelxpert` at the current `/data/app/.../base.apk` and that `android` is absent from PixelXpert scope.
6. Launch PixelXpert, Settings, Dialer, Launcher/SystemUI probes, then hold another post-unlock idle window.

## Not Committed

Raw logcat tails and LSPosed DB snapshots were kept local only because they include personal app data and sensitive attestation-related log lines.
