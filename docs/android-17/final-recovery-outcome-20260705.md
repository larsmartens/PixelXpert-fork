# Android 17 Recovery Outcome - 2026-07-05

Device: Pixel 7 Pro `cheetah` on Android 17 `CP2A.260605.012`, SDK 37.

## Facts

- PixelXpert is installed as a normal data app, not as a mounted `/system/priv-app`.
- PixelXpert's KSU module remains disabled and has `skip_mount` present.
- LSPosed is enabled, but the LSPosed DB has only PixelXpert enabled.
- PixelXpert LSPosed scopes are the packaged declared scopes that are present on this device:
  - `android`
  - `com.android.settings`
  - `com.android.systemui`
  - `com.google.android.apps.nexuslauncher`
  - `com.google.android.dialer`
  - `com.rifsxd.ksunext`
  - `sh.siava.pixelxpert`
- No LSPosed `system` scope rows are present.
- PixelXpert launched successfully after multiple reboots with LSPosed active.
- Settings, Google Dialer, KSU-Next Manager, and PixelXpert launched successfully after enabling the full declared PixelXpert scope list.
- No new `system_server_*` dropbox entries or tombstones appeared after the PixelXpert-only LSPosed activation or after the restored-module reboot.
- Recent non-foreground app/service crash entries appeared for `flix.com.vision` and `com.qorvo.uwb.vendorservice`. These did not coincide with `system_server` PID resets or new `system_server_*` dropbox entries.
- Play Integrity was not recovered in the earlier PIFork/TEESimulator state. Later staged tests found:
  - official TrickyStore v1.4.1: `Fail` for BASIC, DEVICE, and STRONG.
  - KOWX Play Integrity Fix v4.6-inject-s without a keystore module: BASIC pass, DEVICE and STRONG fail.
  - KOWX plus TEESimulator-RS v6.0.1-282: `Fail` for BASIC, DEVICE, and STRONG.
  - AlwaysStrong v1.0.1 after Action refresh: BASIC and DEVICE pass, STRONG fail.
- The earlier STRONG interpretation was invalid because it read only the verdict labels and missed the red X / `Fail` state.
- Enabling `spoofVendingFinger=1` in PIFork while keeping `spoofVendingSdk=0` did not restore an integrity verdict.
- TEESimulator targets were restored to include GMS, GSF, Play Store, both checker packages, and Key Attestation.
- TEESimulator `security_patch.txt` is set to `all=2026-06-05`.
- Zygisk Next v1.4.2 remains active. The standalone PIFork/TEESimulator stack was replaced by AlwaysStrong v1.0.1 after reversible testing because it is the first stack in this session to restore DEVICE integrity.
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
- `tricky_store` / AlwaysStrong v1.0.1

Intentionally still disabled:

- `PixelXpert`: disabled as a KSU mounted module; active as a data app plus LSPosed.
- `rezygisk`: conflicts with the selected Zygisk Next path.
- `zygisk_thanox`: deferred by request.
- `magisk-captive-manager`: already disabled before the session.
- `youtube-morphe-jhc`: module description says to keep disabled because RVMM handles mounting. It was not updated because `/data` had less than 1 GB free and a safe full rollback copy would have been too large.

## Hypotheses

- The original PixelXpert boot stalls were caused by boot-sensitive package/priv-app mount and broad LSPosed startup behavior, not by PixelXpert's data-app UI or a narrow SystemUI scope.
- Android 17 STRONG may still be failing because of keybox validity/revocation, Google account/session state, Android 17 attestation behavior, or current DroidGuard handling.
- The checker UI must be interpreted by icon state / content description (`Pass` or `Fail`) or raw result JSON, not by the presence of `MEETS_*` labels alone.

## Open Items

- YouTube Morphe remains at versionCode `20221061`; latest known release is `20221064`. Update later when enough free space is available for a safe rollback.
- Thanox remains deferred.
- Play Integrity now passes BASIC and DEVICE with AlwaysStrong v1.0.1 after restoring the non-conflicting module set. STRONG remains unresolved.
- KSU-Next kernel/userspace should not be moved to v3.3.0 unless a matching stable Pixel 7 Pro kernel path is selected.
- `flix.com.vision` and `com.qorvo.uwb.vendorservice` produced app/service crash entries after the module restore. They should be treated separately from the PixelXpert/system_server watchdog issue.
- A `keystore2` native tombstone appeared during the AlwaysStrong/PIF/TEE transition at `2026-07-05 18:01`. It has not recurred after the final restored-module reboot, but it should remain a watch item.
- The device lock credential was cleared with `locksettings clear` during final validation because injected unlock input was not reliably reaching the bouncer after repeated reboots. Reconfigure the device screen lock after the work session if desired.

## Rollback

- Disable LSPosed and restore the pre-sanitized DB:
  `/data/adb/pixelxpert-stage/lsposed-pixelxpert-only-20260705-162256/rollback-disable-lsposed-restore-db.sh`
- Restore PIFork `custom.pif.prop` before `spoofVendingFinger=1`:
  `/data/adb/pixelxpert-stage/pif-spoof-vending-fingerprint-20260705-163124/rollback-restore-pif-custom-prop.sh`
- Restore selected module disable state and the previous Unlimited Photos module:
  `/data/adb/pixelxpert-stage/restore-session-modules-20260705-164402/rollback-disable-restored-modules.sh`
- Restore the narrower PixelXpert self/SystemUI LSPosed DB:
  `/data/adb/pixelxpert-stage/pixelxpert-declared-scopes-20260705-165839/rollback-pixelxpert-declared-scopes.sh`
- Restore the pre-AlwaysStrong KOWX/TEESimulator stack:
  `/data/adb/pixelxpert-stage/alwaysstrong-v101-20260705/rollback-restore-pif-tee.sh`

See also `docs/android-17/play-integrity-hybrid-update-20260705.md` for the later Hybrid Mount and Play Integrity update.

Raw device captures remain local under `docs/android-17/evidence/play-integrity-20260705-1610/` and should be reviewed/redacted before committing wholesale.
