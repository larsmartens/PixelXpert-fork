# Root Stack Current Decision - 2026-07-05

Device: Pixel 7 Pro `cheetah`
Build: Android 17 `CP2A.260605.012`, SDK 37

## Facts

- The phone is currently stable on blu_spark r266 `gs-next`.
- Running kernel:
  - `Linux localhost 6.1.157+blu-spark #266 SMP PREEMPT Tue Jun 30 19:09:41 WEST 2026 aarch64`
- blu_spark r266 reports kernel-side KSU `33129`.
- KSU-Next v3.3.0 is the latest upstream KSU-Next release checked on GitHub:
  - <https://github.com/KernelSU-Next/KernelSU-Next/releases/tag/v3.3.0>
  - published 2026-07-03
- KSU-Next userspace/Manager v3.3.0 (`33214`) was already tested on this phone and produced `ksud module install` UAPI mismatch failures against the r266 kernel-side KSU `33129`.
- Live userspace and Manager were aligned back to KSU-Next v3.2.0 (`33129`), restoring normal module-manager compatibility for the current kernel.
- Zygisk Next v1.4.2 is the latest upstream Zygisk Next release checked:
  - <https://github.com/Dr-TSNG/ZygiskNext/releases/tag/v1.4.2>
  - published 2026-06-22
- Zygisk Next v1.4.2 is installed and enabled through the normal KSU module path.
- Process maps confirmed PIF/Zygisk Next artifacts mapped into:
  - `com.google.android.gms.unstable`
  - `com.android.vending`
- A pushed root script, `check-current-module-state-20260705.sh`, confirmed:
  - PixelXpert: disabled, `canary-513`
  - LSPosed: disabled, `v2.1.0 (7769)`
  - Zygisk Next: enabled, `1.4.2 (789-119aaa0-release)`
  - Play Integrity Fork: enabled, `v17`
  - TEESimulator-RS: enabled, `v6.0.1-282`
  - ReZygisk: disabled, `v1.0.0 (515-333d423-release)`

## Research Inputs

- Parallel Search found blu_spark r266 as the current Android 17 June 2026 build for Pixel 6/7/8/9 Tensor devices and `CP2A.260605.012`.
- Parallel Search found KSU-Next v3.3.0 upstream, but no evidence that blu_spark r266 integrates the v3.3.0 kernel-side KSU/UAPI.
- Perplexity review agreed with the conservative decision: do not run userspace ahead of kernel-side KSU when a UAPI mismatch is already reproduced on-device.
- KernelSU documentation still says modules that modify `/system` files need a metamodule, while scripts, sepolicy, and system properties do not necessarily need one. This continues to support PixelXpert's Android 17 default data-app/no-priv-app-mount direction.

## Decision

Do not update the live KSU-Next Manager/userspace back to v3.3.0 on blu_spark r266.

Do not flash another kernel just to chase KSU-Next v3.3.0 or SUSFS. A kernel update is only justified when a Pixel 7 Pro/`cheetah` build explicitly supports Android 17 `CP2A.260605.012` and provides a coherent kernel-side KSU/KSU-Next version that matches its userspace. SUSFS remains desirable but secondary to boot stability.

The current stable root baseline is:

- blu_spark r266 `gs-next`
- KSU-Next userspace/Manager v3.2.0 (`33129`)
- Zygisk Next v1.4.2
- PIF v17
- TEESimulator-RS v6.0.1-282
- PixelXpert disabled
- LSPosed disabled

## Play Integrity Implication

The earlier Play Integrity blocker was provider injection. That gate is now cleared: Zygisk Next is active and PIF maps into the expected GMS unstable and Play Store processes.

The current blocker is different: after confirmed injection, the checker returned an unevaluated response without `deviceRecognitionVerdict`. Logs showed TEESimulator activity, attestation chain rebuilds, StrongBox operation-limit messages, and `KEY_USER_NOT_AUTHENTICATED` messages.

Next Play Integrity tests should change one variable at a time and should not be run repeatedly without cooldown. Candidate variables:

- PIF profile/fingerprint settings for Android 17.
- TEESimulator `security_patch.txt`, including whether `system=no` / `os=-1` is appropriate for this build.
- Keybox validity/revocation state, checked only through redacted/hash-safe tooling.
- GMS/Play Store data state after module changes.
- Google server-side throttling or delayed evaluation after repeated attestation attempts.

Nohello should remain disabled unless a specific root-hiding signal shows it is needed.

## Rollback

Existing rollback paths remain valid:

- Restore live `ksud` v3.3.0 backup:
  - `/data/adb/pixelxpert-stage/ksud-align-3-2-0-20260705-113736/rollback-restore-ksud.sh`
- Reinstall KSU-Next Manager v3.3.0:
  - `/data/adb/pixelxpert-stage/ksunext-manager-downgrade-20260705-113856/rollback-install-ksunext-manager-3-3-0.sh`
- Restore isolated HybridMount module:
  - `/data/adb/pixelxpert-stage/hybridmount-metamodule-isolation-20260705-114125/rollback-restore-hybridmount.sh`
- Disable Zygisk Next:
  - `/data/adb/pixelxpert-stage/zygisknext-enable-20260705-114406/rollback-disable-zygisknext.sh`
