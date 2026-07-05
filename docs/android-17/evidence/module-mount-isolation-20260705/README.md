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

## Current Device State After Isolation

- `sys.boot_completed=1`
- PixelXpert KSU module enabled with `skip_mount=1`
- PixelXpert hooks enabled: `persist.pixelxpert.disable_hooks=0`
- Android 17 unsafe hooks disabled: `persist.pixelxpert.a17.unsafe_scopes=0`
- PixelXpert LSPosed scope excludes `android`
- Hybrid Mount disabled
- AdGuard cert and tailscaled enabled
- V4A, rclone, unlimitedphotos, Thanox disabled pending isolated fixes
- Qorvo UWB vendor service disabled for user 0; rollback is available on-device

## Rollback Commands

- Restore PixelXpert hook kill switch and LSPosed DB:
  `/data/adb/pixelxpert-stage/pixelxpert-hooks-nonsystemserver-20260705-234625/rollback.sh /data/adb/pixelxpert-stage/pixelxpert-hooks-nonsystemserver-20260705-234625`
- Re-enable Qorvo UWB vendor service:
  `/data/adb/pixelxpert-stage/disable-qorvo-uwb-20260705-234910/rollback.sh`
- Restore safe module baseline markers:
  `/data/adb/pixelxpert-stage/safe-module-baseline-20260705-233846/rollback.sh /data/adb/pixelxpert-stage/safe-module-baseline-20260705-233846`

## Code Fixes Added

- `ScreenGestures`: construct the lockscreen double-tap detector with `Handler(Looper.getMainLooper())`.
- `StatusbarGestures`: construct pull-down and pull-up gesture detectors with `Handler(Looper.getMainLooper())`.
- `KeyguardMods`: skip the Android 17 keyguard constraint hook until the custom text view and placeholder ID are available.

## Not Committed

Raw logcat tails and LSPosed DB snapshots were kept local only because they include personal app data and Play Integrity/keybox-related log lines.
