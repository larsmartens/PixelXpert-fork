# KSU-Next Alignment And Zygisk Next Evidence - 2026-07-05

Device: Pixel 7 Pro `cheetah`
Build: Android 17 `CP2A.260605.012`, SDK 37
Root context: KernelSU/KSU-Next shell, `u:r:ksu:s0`

## Facts

- KSU-Next v3.3.0 remains the latest upstream release checked on GitHub, but blu_spark r266 `gs-next` reports kernel-side KSU `33129`.
- With KSU-Next Manager/`ksud` v3.3.0 (`33214`) on blu_spark r266, `ksud module install` failed with a UAPI mismatch.
- Staged `ksud` v3.2.0 (`33129`) successfully ran:
  - `module list`
  - `module install --help`
- Live `/data/adb/ksud` was aligned from v3.3.0 to v3.2.0.
- KSU-Next Manager was aligned from v3.3.0 to v3.2.0 because Android rejected a direct downgrade install with `INSTALL_FAILED_VERSION_DOWNGRADE`; the final path was uninstall/reinstall with rollback APK staged.
- The disabled `hybrid_mount` metamodule blocked normal root-manager module installation with `Metamodule installation blocked`. It was moved out of `/data/adb/modules` and preserved under `/data/adb/pixelxpert-stage`.
- Zygisk Next v1.4.2 was then installed through the normal KSU module installer and enabled in a separate step.

## Installed State

- Running kernel:
  - `Linux localhost 6.1.157+blu-spark #266 SMP PREEMPT Tue Jun 30 19:09:41 WEST 2026 aarch64`
- Live userspace:
  - `/data/adb/ksud -V`: `ksud 3.2.0`
- KSU-Next Manager:
  - `versionCode=33129`
  - `versionName=v3.2.0`
- Zygisk Next:
  - module id `zygisksu`
  - version `1.4.2 (789-119aaa0-release)`
  - enabled
  - description reports `Root: KernelSU (33129)` and `ZL`
- Play Integrity Fork:
  - module id `playintegrityfix`
  - enabled
- TEESimulator-RS:
  - module id `tricky_store`
  - version `v6.0.1-282`
  - enabled
- PixelXpert:
  - module id `PixelXpert`
  - disabled
- LSPosed:
  - module id `zygisk_lsposed`
  - disabled
- ReZygisk and Nohello:
  - disabled

## Verification

- `adb shell su -c id` returned root in `u:r:ksu:s0`.
- `sys.boot_completed=1` after the apply and enable reboots.
- Zygisk Next status reported:
  - `zygote_states:1`
  - `inject_state:1`
  - `root_status: KernelSU (33129)`
  - `modules64: playintegrityfix`
  - `modules_with_issue:0`
- Runtime processes included:
  - `zn-daemon`
  - `zn-nsdaemon-zygote`
  - `zn-zygisk-companion64 playintegrityfix`
- Process maps showed `playintegrityfix/zygisk/arm64-v8a.so` and `zygisksu/lib64/libzygisk.so` mapped into:
  - `com.google.android.gms.unstable`
  - `com.android.vending`
- Process maps did not show PIF mapped into the main `com.google.android.gms` process. This is expected for the DroidGuard-focused path and is not by itself a failure.
- No newer `system_server_crash`, `system_server_watchdog`, `system_server_pre_watchdog`, or `system_server_anr` dropbox entries appeared after the Zygisk Next enable boot. The newest relevant entry remained:
  - `/data/system/dropbox/system_server_pre_watchdog@1783184076537.txt.gz`
- No newer tombstones appeared after 2026-07-04 15:15.

## Play Integrity Result

After KSU userspace/kernel alignment and confirmed Zygisk Next/PIF injection, Simple Play Integrity Checker returned an unevaluated response with no `deviceRecognitionVerdict`.

Observed response fields:

```text
appRecognitionVerdict: UNEVALUATED
deviceActivityLevel: UNEVALUATED
appLicensingVerdict: UNEVALUATED
playProtectVerdict: UNEVALUATED
deviceAttributes: {}
```

Log evidence during the check showed:

- TEESimulator active for the GMS UID.
- TEESimulator using the configured keybox file. Keybox contents were not printed or committed.
- Rebuilt attestation chains.
- Attestation patch levels included `os=-1`, `vendor=20260605`, and `boot=20260605`.
- StrongBox operation-limit messages for the GMS UID.
- Keystore `KEY_USER_NOT_AUTHENTICATED` messages for the GMS UID with expired auth tokens.

## Interpretation

The root/Zygisk provider failure has been resolved for the current stable path: Zygisk Next is active and PIF is injected into the expected Play Integrity target processes.

The remaining Play Integrity failure is therefore not primarily a Zygisk provider loading problem and not a Nohello problem. The next variables are PIF profile/settings, TEESimulator-RS configuration, keybox validity/revocation state, Google server-side throttling or delayed evaluation, and current Android 17/GMS behavior.

Do not hammer Play Integrity immediately after an unevaluated response: the logs already show StrongBox operation limiting and key-authentication expiry paths.

## PixelXpert Architecture Implications

Repo inspection found no current PixelXpert app code path that inherently requires privileged or system-app placement.

Facts:

- The app manifest declares ordinary app-facing permissions and no `sharedUserId`, platform signature dependency, or privileged-only permission.
- `RootProvider` keeps `/system/priv-app/PixelXpert/PixelXpert.apk` only as a fallback when `PackageManager.sourceDir` lookup fails.
- Root grants, LSPosed/Vector scope insertion, module mount policy, and Android 17 data-app installation are already handled by root/module scripts and root shell paths.
- Xposed behavior is driven by LSPosed package scope, not by privileged app placement.
- The exported `PixelXpertProxy` root command path validates caller package membership and does not require the APK itself to be a priv-app.

Hypotheses:

- A remaining boot stall with LSPosed self-scope only is more likely from the boot-sensitive package scan/mount path or the app's own self-scope startup than from SystemUI/Launcher/Dialer hooks.
- `/system/priv-app` mounting should remain Android 17 opt-in only. The boot-safe default should be data-app APK plus root/module helper scripts.

Open questions:

- Which self-scope startup block, if any, can still delay PixelXpert app launch or preference initialization on Android 17.
- Whether a full reboot with the current data-app artifact, PixelXpert module still disabled, and LSPosed still disabled remains stable across a longer idle window.
- Which feature groups need explicit Android 17 revalidation before adding Launcher, Dialer, Phone, Settings, or broader scopes.

## Android 17 Hook Risk Notes

Facts:

- `persist.pixelxpert.disable_hooks=1` remains the global hook kill switch.
- Android 17 skips `system_server`/framework hook loading by default.
- Android 17 also skips generated Common, Framework, and Telecom modpacks unless `persist.pixelxpert.a17.unsafe_scopes=1` is set.
- SystemUI, Launcher, and Dialer hooks are code-allowed, but module scripts no longer auto-scope them on Android 17 unless `a17_enable_default_scopes` exists or scopes are added manually.

Highest-risk hook areas before broader activation:

- SystemUI shade/scene migration: `ScreenGestures`, `StatusbarGestures`, `QSTileGrid`, `KeyguardMods`, and `StatusbarMods` still depend on direct SystemUI class and method names, with some Android 17 QPR1 fallbacks already present.
- Launcher: `HideNavigationBarInsets` uses hard reflection instead of optional/safe reflection, `TaskbarActivator` has unguarded method discovery, and navigation gesture hooks rely on R8-unstable Launcher/Quickstep internals.
- Dialer/Telecom: Dialer resource hooks need resource-name validation; Telecom `CallVibrator` remains Android 17-disabled with the broader Telecom gate.

Tests and CI guards to add:

- Source-level Android 17 modpack inventory guard: assert SDK 37 default policy excludes Common, Framework, and Telecom and permits only explicitly staged package scopes.
- Reflection safety guard: fail CI for direct `ReflectedClass.of("com.android...")`, plain `.run(...)`, or unguarded method discovery in SystemUI/Launcher/Dialer/framework modpacks unless explicitly allowlisted.
- Android 17 class/method presence manifest: generate from the target device/build classpath and classify every hook target as `present`, `fallback`, `disabled`, or `unknown-fail`.
- Loader behavior tests: assert SDK 37 skips `system_server`, defers non-self package hook loading until boot complete, and blocks Common/Framework/Telecom unless the unsafe property is enabled.
- Packaging shell tests with stubbed `getprop`, `pm`, and filesystem roots: assert SDK 37 creates `skip_mount`, uses data-app install, resolves `pm path`, and scopes self-only by default.
- Zip-content assertions: assert no `a17_enable_privapp_mount` marker ships by default, module scripts are syntax-checked, bundled `sqlite3` is executable, and all packaging tasks place the same APK path in the zip.
- Build-script guard: keep `compileSdk = 37` and avoid raising `targetSdk` without an explicit Android 17 compatibility review.

## Rollback Paths

- Restore live `ksud` v3.3.0 backup:
  - `/data/adb/pixelxpert-stage/ksud-align-3-2-0-20260705-113736/rollback-restore-ksud.sh`
- Reinstall KSU-Next Manager v3.3.0:
  - `/data/adb/pixelxpert-stage/ksunext-manager-downgrade-20260705-113856/rollback-install-ksunext-manager-3-3-0.sh`
- Restore isolated HybridMount module:
  - `/data/adb/pixelxpert-stage/hybridmount-metamodule-isolation-20260705-114125/rollback-restore-hybridmount.sh`
- Restore previous Zygisk provider state:
  - `/data/adb/pixelxpert-stage/zygisknext-normal-20260705-114132/rollback-restore-zygisk-provider.sh`
- Disable Zygisk Next:
  - `/data/adb/pixelxpert-stage/zygisknext-enable-20260705-114406/rollback-disable-zygisknext.sh`

## Research Notes

- KernelSU documents that modules modifying `/system` files need a metamodule, while script/sepolicy/system.prop modules do not necessarily need one. This supports keeping PixelXpert's Android 17 default away from `/system/priv-app` mounting unless explicitly opted in.
- Play Integrity Fork documents KSU/KSU-Next support through Zygisk Next/ReZygisk/NeoZygisk and recommends official Tricky Store or TEESimulator for Android 13+ DEVICE/STRONG attempts. It also warns that Pixel Beta/Canary fingerprints are not enough by themselves for DEVICE on current Android.
- TEESimulator-RS documents a valid `/data/adb/tricky_store/keybox.xml`, target configuration, per-package `security_patch.txt`, and per-UID rate limiting as material configuration points.

References:

- KSU-Next v3.3.0: <https://github.com/KernelSU-Next/KernelSU-Next/releases/tag/v3.3.0>
- Zygisk Next v1.4.2: <https://github.com/Dr-TSNG/ZygiskNext/releases/tag/v1.4.2>
- KernelSU installation/metamodule guide: <https://kernelsu.org/guide/installation.html>
- Play Integrity Fork README: <https://github.com/osm0sis/PlayIntegrityFork>
- TEESimulator-RS README: <https://github.com/Enginex0/TEESimulator-RS>
