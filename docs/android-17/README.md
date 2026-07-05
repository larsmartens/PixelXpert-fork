# Android 17 Investigation Handoff

Date: 2026-07-04

This directory records the Android 17 device work on a Pixel 7 Pro (`cheetah`) running build `CP2A.260605.012`, SDK 37, with KSU-Next, Zygisk providers, LSPosed/Vector, Play Integrity Fork, and TEESimulator-RS.

## Current Device State

- PixelXpert module is staged but disabled:
  - `/data/adb/modules/PixelXpert/disable`
  - staged version: `canary-513`
  - staged CI zip SHA256: `2c26d3a6cd6a7a5f6e7b2ec1047e360af14f8b132c9b9b800f76d7ac2864dc0e`
- KSU-Next Manager was updated to v3.3.0 and blu_spark was updated to r266 `gs-next`; see `evidence/ksu-next-manager-kernel-update-20260705.md`.
- The latest checked blu_spark r266 KSU-Next kernel still reports KernelSU `33129`, while userspace is `ksud 3.3.0 (uapi: 2)`.
- `ksud module list` works, but `ksud module install` fails with a UAPI mismatch. Treat module installs as unsafe until the KSU-Next userspace/kernel mismatch is resolved.
- Current Zygisk provider state is conservative after Play Integrity experiments:
  - NeoZygisk v2.3 is installed as `zygisksu` but disabled.
  - ReZygisk v1.0.0 is installed but disabled.
  - LSPosed is disabled.
  - Nohello is disabled.
- Play Integrity improved from no verdicts to BASIC-only during a ReZygisk manual-start experiment, then the stack was returned to a no-provider stable state. See `evidence/play-integrity-root-stack-20260705.md`.
- As of the latest validation, the phone idled for 75 seconds with `system_server` running and no new tombstones after disabling NeoZygisk/ReZygisk provider processes.

## Commits On Investigation Branch

Branch: `fix/prefs-startup-watchdog`

- `df20aae0` `fix: avoid blocking system_server on preference startup`
- `f7e3d479` `fix: disable Android 17 system-server hooks`
- `2a5f543a` `fix: limit Android 17 default PixelXpert scopes`
- `52c0c2de` `fix: preserve PixelXpert scopes on boot`
- `772db139` `fix: defer Android 17 hooks until boot complete`
- `1cf3ba9b` `fix: make Android 17 activation safe by default`

GitHub Actions run for `1cf3ba9b`:

- URL: https://github.com/larsmartens/PixelXpert-fork/actions/runs/28707948082
- Result: success
- Jobs passed: `zip integrity`, `static module guards`, `assembleRelease`, `assembleDebug`, `dependency validation`, `lint`

## PixelXpert Findings

Earlier failures with broad LSPosed scopes showed a real PixelXpert startup bug:

- `system_server`/Telecom main thread blocked through `RemotePreferences`.
- Stack included `ActivityThread.acquireProvider -> RemotePreferences.getBoolean -> XPLauncher.waitForXprefsLoad -> HookHelper -> ActivityThread.handleCreateService`.
- This led to `system_server_anr`, `system_server_pre_watchdog`, and `system_server_watchdog` entries.

The current branch hardens that path:

- Preference probing is bounded and fail-closed.
- Android 17 system_server hooks are skipped.
- Android 17 hook loading waits for `sys.boot_completed`.
- Android 17 default auto-scope is now self-only unless a marker opt-in exists.
- A property kill switch exists:
  - `persist.pixelxpert.disable_hooks=1`
- Unsafe Android 17 scope filtering can be explicitly bypassed for experiments:
  - `persist.pixelxpert.a17.unsafe_scopes=1`

However, testing the CI artifact from `1cf3ba9b` still stalled boot even with LSPosed scope reduced to only:

- `sh.siava.pixelxpert`

That means the remaining Android 17 failure is likely not simply SystemUI/Launcher/Dialer hook scope. The leading hypothesis is that the `/system/priv-app/PixelXpert` mount/package-scan path is unsafe on this Android 17/root/Vector stack. Another hypothesis is interaction with other LSPosed modules in `system` scope, but PixelXpert self-only still reproducing makes the priv-app mount path the first thing to challenge.

## Current Unlock Crash Findings

The latest snapshot after the user reported reboot/crash after unlock is in:

- `docs/android-17/evidence/current-state-snapshot-20260704-171859.md`

Key lines from that snapshot:

- PixelXpert was disabled at capture time.
- Fresh dropbox entries existed around 2026-07-04 17:16-17:18:
  - `system_server_pre_watchdog@1783178203949.txt.gz`
  - `system_server_anr@1783178182432.txt.gz`
  - `system_server_watchdog@1783178255409.txt.gz`
  - `system_server_anr@1783178303324.txt.gz`
  - `system_server_pre_watchdog@1783178323478.txt.gz`
- Logcat near unlock showed:
  - repeated `system_server` SELinux denials reading `l53202`
  - `LSPosedFramework` exception in `(system)[unknown,XposedBridge,...] com.xposed.XSupport.handleLoadPackage(SourceFile:77)`
  - `TEESimulator` work for UID `10129` and `StrongBox op limit reached`
  - `DeadSystemException: The system died; earlier logs will point to the root cause`

Preliminary decision: treat the current unlock reboot as a broader root-stack/LSPosed/TEESimulator issue until proven otherwise. Do not assume it is PixelXpert, because PixelXpert was disabled when the snapshot was captured.

## Play Integrity Findings

Additional 2026-07-05 findings:

- PIFork v17 and TEESimulator-RS remain installed, but no active Zygisk provider is currently running.
- ReZygisk v1.0.0 manual start loaded `playintegrityfix` into `zygiskd64`, but did not inject the 64-bit zygote.
- That ReZygisk experiment returned only `MEETS_BASIC_INTEGRITY`.
- NeoZygisk v2.3 manual activation caused Android framework services to remain unavailable after zygote restart until the NeoZygisk monitor/daemon were killed and the module was disabled.
- Process-map checks showed no PIF/TEESimulator/Zygisk artifacts inside GMS, Play Store, or the checker during the provider-failure tests.
- Next gate: resolve KSU-Next userspace/kernel mismatch and verify real Zygisk injection before burning more Play Integrity checks.

Changes made:

- Zygisk Next updated from `1.4.1` to `1.4.2`.
- Tricky Store / TEESimulator target list reduced from 312 entries to a focused Play Integrity set:
  - `com.google.android.gms`
  - `com.google.android.gsf`
  - `com.android.vending`
  - `com.henrikherzig.playintegritychecker`
  - `gr.nikolasspyr.integritycheck`
  - `io.github.vvb2060.keyattestation`
- TEESimulator `security_patch.txt` aligned to the installed PIF script format:
  - `all=2026-06-05`
  - `[com.google.android.gms] system=no`

Result:

- Simple Play Integrity Checker still returned `NO_INTEGRITY`.
- Logs showed TEESimulator generating keybox-backed software keys and rebuilding chains, so the remaining blocker may be server-side rejection of the keybox/profile rather than stale GMS state.
- Do not print or commit keybox contents. The committed evidence includes only the keybox SHA256 hash.

## Rollback Paths

PixelXpert rollback scripts left on the device:

- `/data/adb/pixelxpert-stage/a17-self-scope-20260704-154228/rollback_disable_pixelxpert.sh`
- `/data/adb/pixelxpert-stage/activate-self-scope-20260704-154343/rollback_disable_pixelxpert.sh`

Tricky Store config rollback scripts left on the device:

- `/data/adb/tricky_store/backups/play-integrity-opt-20260704-152235/rollback_restore_tricky_store_config.sh`
- `/data/adb/tricky_store/backups/teesim-security-patch-20260704-152707/rollback_restore_security_patch.sh`

Zygisk Next rollback path:

- `/data/adb/zygisk-next-update/backup-20260704-151506/rollback_restore_zygisk_next.sh`

## Suggested Next Technical Direction

1. Stabilize the phone first. Because current crashes occur with PixelXpert disabled, isolate root-stack modules before further PixelXpert activation tests.
2. Inspect the fresh dropbox files from 17:16-17:18 and identify the exact blocked thread and package/module interaction.
3. Temporarily disable or de-scope third-party LSPosed modules active in `system`, especially unknown/obfuscated modules, then retest unlock stability.
4. Reassess TEESimulator config after unlock stability. If needed, roll back the Tricky Store target/security patch changes above and retest.
5. For PixelXpert Android 17 compatibility, prototype a non-priv-app install path:
   - keep module zip for native/libs/scripts/root provider only
   - install PixelXpert APK as data app or standard LSPosed module
   - avoid `/system/priv-app/PixelXpert` package scan during boot
6. Re-enable PixelXpert one variable at a time:
   - mounted but LSPosed disabled
   - data-app APK with self-only LSPosed scope
   - SystemUI scope only
   - Launcher scope only
   - Dialer scope only
   - feature subsets inside each scope

Do not remove `/data/adb/modules/PixelXpert/disable` until a rollback script and a current dropbox baseline exist.
