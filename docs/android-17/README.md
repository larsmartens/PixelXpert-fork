# Android 17 Investigation Handoff

Date: 2026-07-05

This directory records the Android 17 device work on a Pixel 7 Pro (`cheetah`) running build `CP2A.260605.012`, SDK 37, with KSU-Next, Zygisk providers, LSPosed/Vector, Play Integrity modules, and PixelXpert's Android 17 boot-safe architecture.

Latest validation: see `module-integrity-validation-20260706.md`. That newer note supersedes the 2026-07-05 state for Hybrid Mount, PixelXpert module markers, and the Play Integrity stack.

## Current Device State

- PixelXpert is installed as a normal data app and launches successfully:
  - package: `sh.siava.pixelxpert`
  - version: `canary-513`
  - launcher alias: `.FakeSplashActivityNormalIcon`
- PixelXpert's KSU module is enabled as a helper/module payload, but `skip_mount` is present and should remain the durable boot-safety control:
  - `/data/adb/modules/PixelXpert/skip_mount`
- PixelXpert is enabled in LSPosed with declared scopes only:
  - `com.android.settings`
  - `com.android.systemui`
  - `com.google.android.apps.nexuslauncher`
  - `com.google.android.dialer`
  - `com.rifsxd.ksunext`
  - `sh.siava.pixelxpert`
- No PixelXpert LSPosed `android`, `system`, or `system_server` scope row is present.
- PixelXpert, Settings, Google Dialer, Google Photos, AdGuard, and SPIC launched after the final restored-module reboot.
- KSU-Next Manager was updated to v3.3.0 and blu_spark was updated to r266 `gs-next`; see `evidence/ksu-next-manager-kernel-update-20260705.md`.
- blu_spark r266 still reports kernel-side KSU `33129`, so live KSU userspace and Manager were aligned back to v3.2.0 (`33129`) after v3.3.0 caused `ksud module install` UAPI mismatch failures.
- Hybrid Mount Lite is active again as module id `hybrid_mount`, version `4.2.0-1815`. The 2026-07-06 validation has Unlimited Photos, AdGuard certificate, and rclone using Hybrid magic markers.
- Current enabled module stack after the 2026-07-06 validation:
  - Zygisk Next v1.4.2
  - LSPosed v2.1.0
  - KOWX Play Integrity Fix v4.6-inject-s
  - official TrickyStore v1.4.1
  - KOWX Tricky Addon v4.4
  - Zygisk Detach v1.23.1
  - NoHello v0.0.7
  - Unlimited Photos v3
  - Tailscaled v2.0.0.1
  - rclone v1.16 module with mounted rclone binaries
  - rvmm-zygisk-mount v9
  - ViPER4Android RE Fork v8.0
  - AdGuard cert v2.2.0-beta.7
- Current intentionally disabled modules:
  - PixelXpert KSU module
  - Captive Manager
  - ReZygisk
  - Thanox
  - YouTube Morphe
- Play Integrity currently passes DEVICE with the KOWX PIF plus official TrickyStore stack. STRONG still fails. See `module-integrity-validation-20260706.md`.
- The current root-stack decision is recorded in `evidence/root-stack-current-decision-20260705.md`: stay on blu_spark r266 `gs-next` with KSU-Next userspace/Manager v3.2.0 (`33129`) until a kernel explicitly integrates a newer KSU-Next userspace/UAPI.
- As of the latest validation, there were no new `system_server_*` dropbox entries after the restored-module reboot. The newest tombstones remained from `2026-07-06 01:21`.
- Google Play services still reports `BadAuthentication` / `UNAUTHENTICATED` and account-action-required notifications. Treat this as a separate account/session item before more Play Integrity tuning.

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

Later docs/evidence commit:

- `fb2309d5` `docs: record android 17 integrity update`
- GitHub Actions run: https://github.com/larsmartens/PixelXpert-fork/actions/runs/28747005645
- Result: success
- Jobs passed: `static module guards`, `assembleDebug`, `assembleRelease`, `lint`, `dependency validation`, `zip integrity`

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

Testing the CI artifact from `1cf3ba9b` still stalled boot when installed through the old mounted `/system/priv-app` module path even with LSPosed scope reduced to only:

- `sh.siava.pixelxpert`

That means the remaining Android 17 failure was likely not simply SystemUI/Launcher/Dialer hook scope. The staged safe path is now data-app PixelXpert plus LSPosed declared scopes, with the KSU mounted module disabled and `skip_mount` present.

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

Decision: treat the July 4 unlock reboot as a broader root-stack/LSPosed/TEE issue until proven otherwise. Do not assume it was PixelXpert, because PixelXpert was disabled when the snapshot was captured. No new `system_server_*` dropbox entries appeared after the July 5 data-app/LSPosed declared-scope validation.

## Play Integrity Findings

Additional 2026-07-05 findings before KSU alignment:

- PIFork v17 and TEESimulator-RS remain installed, but no active Zygisk provider is currently running.
- ReZygisk v1.0.0 manual start loaded `playintegrityfix` into `zygiskd64`, but did not inject the 64-bit zygote.
- That ReZygisk experiment returned only `MEETS_BASIC_INTEGRITY`.
- NeoZygisk v2.3 manual activation caused Android framework services to remain unavailable after zygote restart until the NeoZygisk monitor/daemon were killed and the module was disabled.
- Process-map checks showed no PIF/TEESimulator/Zygisk artifacts inside GMS, Play Store, or the checker during the provider-failure tests.
- That gate has now been cleared by aligning KSU userspace/Manager to v3.2.0 and installing Zygisk Next v1.4.2 through the normal root-manager path.

Additional 2026-07-05 findings after KSU alignment:

- Zygisk Next v1.4.2 is enabled and reports KernelSU root `33129`.
- Process maps show PIF and Zygisk Next mapped into `com.google.android.gms.unstable` and `com.android.vending`.
- Play Integrity still returned an unevaluated/no-verdict response.
- Logs show TEESimulator activity for GMS, attestation chain rebuilds, StrongBox operation limits, and key-authentication expiry messages.
- Next gate: do not repeatedly test Play Integrity immediately. After cooldown, investigate TEESimulator/PIF profile and security patch configuration one variable at a time.

Later 2026-07-05 findings:

- Official TrickyStore v1.4.1 produced BASIC/DEVICE/STRONG fail on this build.
- KOWX Play Integrity Fix v4.6-inject-s without a keystore module produced BASIC pass only.
- KOWX plus TEESimulator-RS v6.0.1-282 produced BASIC/DEVICE/STRONG fail.
- AlwaysStrong v1.0.1 produced BASIC plus DEVICE pass and STRONG fail after its Action refresh.
- The standalone PIF/TEESimulator stack has been replaced by AlwaysStrong v1.0.1. A rollback script for the pre-AlwaysStrong stack exists on-device.
- The earlier STRONG interpretation was invalid because it read label presence instead of the checker icon `Pass` / `Fail` state.

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

- Play Integrity is no longer `NO_INTEGRITY` in the final AlwaysStrong state. BASIC and DEVICE pass; STRONG fails.
- The remaining STRONG blocker may be keybox validity/revocation, Android 17 attestation behavior, DroidGuard handling, or Google account/session state.
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

KSU/Zygisk alignment rollback paths:

- `/data/adb/pixelxpert-stage/ksud-align-3-2-0-20260705-113736/rollback-restore-ksud.sh`
- `/data/adb/pixelxpert-stage/ksunext-manager-downgrade-20260705-113856/rollback-install-ksunext-manager-3-3-0.sh`
- `/data/adb/pixelxpert-stage/hybridmount-metamodule-isolation-20260705-114125/rollback-restore-hybridmount.sh`
- `/data/adb/pixelxpert-stage/zygisknext-normal-20260705-114132/rollback-restore-zygisk-provider.sh`
- `/data/adb/pixelxpert-stage/zygisknext-enable-20260705-114406/rollback-disable-zygisknext.sh`

Later rollback paths:

- Restore the narrower PixelXpert self/SystemUI LSPosed DB:
  `/data/adb/pixelxpert-stage/pixelxpert-declared-scopes-20260705-165839/rollback-pixelxpert-declared-scopes.sh`
- Restore the pre-AlwaysStrong KOWX/TEESimulator stack:
  `/data/adb/pixelxpert-stage/alwaysstrong-v101-20260705/rollback-restore-pif-tee.sh`
- Restore nonessential module isolation:
  `/data/adb/pixelxpert-stage/play-integrity-nonessential-isolation-20260705-171422/rollback-restore-nonessential-modules.sh`

## Suggested Next Technical Direction

1. Keep PixelXpert on the data-app plus LSPosed path while refactoring Android 17 hooks. Do not re-enable the mounted KSU module unless a staged rollback plan requires it.
2. Reassess stale Android 17 hook names/classes by scope, starting with SystemUI and Launcher, before enabling feature-heavy paths.
3. Resolve Google account/session reauth before further Play Integrity tuning; current BASIC+DEVICE pass proves the remaining account issue is separate from the old `NO_INTEGRITY` state.
4. For PixelXpert Android 17 compatibility, continue the non-priv-app architecture:
   - keep module zip for native/libs/scripts/root provider only
   - install PixelXpert APK as data app or standard LSPosed module
   - avoid `/system/priv-app/PixelXpert` package scan during boot
5. Test PixelXpert one variable at a time:
   - data-app APK with declared LSPosed scopes
   - SystemUI scope only
   - Launcher scope only
   - Dialer scope only
   - feature subsets inside each scope
6. Add and maintain GitHub Actions guards for Android 17 boot-safe policy; do not compile locally on this laptop.

Do not remove `/data/adb/modules/PixelXpert/disable` until a rollback script and a current dropbox baseline exist.
