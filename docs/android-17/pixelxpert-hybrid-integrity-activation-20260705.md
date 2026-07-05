# Android 17 Activation Plan And Outcome - 2026-07-05

## Scope

This report covers the staged activation work for:

1. PixelXpert fully functional and enabled without reintroducing the Android 17 boot-sensitive priv-app mount.
2. Hybrid Mount review and a bounded activation attempt for modules that genuinely need `/system` or APEX mounts, especially `adguardcert`.
3. Play Integrity recovery toward STRONG, or at least the next verdict below STRONG.

The implementation followed the laptop-led adb workflow. No local Gradle compile was run.

## Review Feedback

A separate Codex review thread checked the proposed plan against the repo and captured evidence. Its recommendation was:

- Keep PixelXpert as a normal data app plus LSPosed module.
- Keep `/data/adb/modules/PixelXpert/skip_mount` present.
- Do not create `a17_enable_privapp_mount`; the old `/system/priv-app/PixelXpert` path is the boot-sensitive path.
- Hybrid Mount is potentially useful for modules that really modify `/system` or APEX paths. `adguardcert` qualifies because it injects certs under `/system/etc/security/cacerts` and `/apex/com.android.conscrypt/cacerts`.
- Prefer Hybrid Mount Lite or Nano before Full/Kasumi.
- Treat STRONG as dependent on a coherent, non-revoked keybox and attestation stack. BASIC+DEVICE is the realistic stable plateau unless a better keybox path is proven.

## Facts

- Device: Pixel 7 Pro `cheetah`, Android 17 `CP2A.260605.012`, SDK 37.
- Root context: KernelSU/KSU-Next root shell, `u:r:ksu:s0`.
- PixelXpert package is installed as a data app: `package:/data/app/.../sh.siava.pixelxpert.../base.apk`.
- PixelXpert version: `canary-513`.
- LSPosed has PixelXpert enabled with scopes for `android`, `com.android.settings`, `com.android.systemui`, `com.google.android.apps.nexuslauncher`, `com.google.android.dialer`, `com.rifsxd.ksunext`, and `sh.siava.pixelxpert`.
- PixelXpert KSU module is enabled, but `skip_mount=1` remains present.
- `a17_enable_privapp_mount` is absent.
- PixelXpert, Settings, and Dialer all launch after reboot in this state.
- A 10 minute idle window after PixelXpert activation did not create new `system_server_*` dropbox entries.
- Hybrid Mount Lite v4.2.0-1815 is the current upstream release as of this run.
- AlwaysStrong v1.0.1 is the current upstream release as of this run.
- Play Integrity now passes BASIC and DEVICE, but fails STRONG.

## Hypotheses

- PixelXpert’s previous Android 17 boot stall was caused by boot-time package scanning and privileged/system placement interactions, not by normal LSPosed self-scope alone.
- PixelXpert can be treated as a data-app UI plus LSPosed hooks plus root/module helper, with privileged placement avoided.
- Hybrid Mount Lite on this Android 17/blu_spark/KSU-Next stack currently breaks early framework service startup when enabled globally, even with PixelXpert’s priv-app path ignored.
- STRONG failure is most likely caused by attestation/keybox trust or coherence, not PixelXpert. The current stack can produce DEVICE after the SIM/keyguard issue is cleared.

## Open Questions

- Whether a narrower Hybrid Mount config can avoid the WiFi HAL `system_server` crash while still mounting only `adguardcert`.
- Whether Hybrid Mount Nano behaves differently from Lite on this build.
- Whether STRONG is possible with a different non-revoked keybox and the current TEESimulator/AlwaysStrong implementation without destabilizing DEVICE.
- Whether Google account reauthentication should be completed before further STRONG experiments, given recurring `BadAuthentication` and `UNAUTHENTICATED` logs.

## Adjusted Plan

### Phase 1: PixelXpert No-Mount Activation

1. Back up PixelXpert module markers and LSPosed DB/WAL/SHM.
2. Ensure `skip_mount` exists.
3. Remove `disable` from `/data/adb/modules/PixelXpert`.
4. Ensure `a17_enable_privapp_mount` is absent.
5. Ensure LSPosed scopes use the data-app APK path and do not add `system`.
6. Reboot.
7. Validate boot completion, app launches, LSPosed rows, and a sustained idle window.

Rollback:

- Run `/data/adb/pixelxpert-stage/pixelxpert-no-mount-20260705/rollback.sh`, or recreate `/data/adb/modules/PixelXpert/disable` and keep `skip_mount`.

### Phase 2: Hybrid Mount For System/APEX Modules

1. Download Hybrid Mount Lite v4.2.0-1815 and verify SHA-256.
2. Back up existing Hybrid Mount config and module directories.
3. Install Hybrid Mount Lite.
4. Configure `adguardcert` cert paths as `magic`.
5. Configure PixelXpert’s old `system/priv-app/PixelXpert` path as `ignore`.
6. Reboot and validate boot completion, module state, cert mounts, and dropbox/tombstones.
7. If boot does not complete or `system_server` crashes appear, disable Hybrid Mount and reboot.

Rollback:

- Run `/data/adb/pixelxpert-stage/hybrid-mount-lite-20260705/rollback-disable-hybrid-mount.sh`.

### Phase 3: Play Integrity

1. Stabilize PixelXpert and Hybrid state first.
2. Clear SIM/keyguard blockers so checkers can run in foreground.
3. Run two checkers and preserve screenshots/XML.
4. Inspect integrity modules and logs without printing keybox contents.
5. Only attempt STRONG-changing module/keybox changes if there is a clear, reversible hypothesis.

Rollback:

- Use existing staged rollback scripts under `/data/adb/pixelxpert-stage/`.
- Do not overwrite keybox material without hashing and backing up first.

## Outcome

### PixelXpert

PixelXpert is enabled and running in the safe data-app plus LSPosed architecture. The KSU module remains enabled only as a helper/scripts container and is not mounted into `/system` because `skip_mount=1` is present.

Evidence:

- `evidence/plan-activation-20260705/pixelxpert-no-mount-activation-output.txt`
- `evidence/plan-activation-20260705/post-reboot-pixelxpert-no-mount-state.txt`
- `evidence/plan-activation-20260705/post-pixelxpert-idle-10min-state.txt`
- `evidence/plan-activation-20260705/post-hybrid-rollback-launch-checks.txt`
- `evidence/plan-activation-20260705/final-idle-state.txt`

### Hybrid Mount

Hybrid Mount Lite was installed and configured, but the activation reboot did not reach `sys.boot_completed=1`. The staged rollback was executed successfully and the next boot completed.

Post-rollback evidence shows:

- `hybrid_mount state=disabled`
- PixelXpert still enabled with `skip_mount=1`
- PixelXpert, Settings, and Dialer launch successfully

The Hybrid Mount boot hang produced repeated `system_server_crash` entries. A representative crash shows:

`java.lang.RuntimeException: Failed to create service com.android.server.wifi.WifiService`

caused by:

`java.util.NoSuchElementException` in `android.os.HwBinder.getService`, while starting the WiFi HAL path.

This makes Hybrid Mount Lite unsafe to keep enabled on this build. `adguardcert` remains enabled, and its cert mounts were already active before the Hybrid Mount activation attempt.

Evidence:

- `evidence/plan-activation-20260705/pre-hybrid-reboot-state.txt`
- `evidence/plan-activation-20260705/hybrid-mount-lite-install-output.txt`
- `evidence/plan-activation-20260705/post-hybrid-rollback-state.txt`
- `evidence/plan-activation-20260705/hybrid-mount-system-server-crash.txt`
- `evidence/plan-activation-20260705/hybrid-mount-crash-summary.txt`

### Play Integrity

After clearing the SIM PIN screen and rerunning two checkers:

- `MEETS_BASIC_INTEGRITY`: pass
- `MEETS_DEVICE_INTEGRITY`: pass
- `MEETS_STRONG_INTEGRITY`: fail

This satisfies the fallback target of the level below STRONG. STRONG was not achieved.

Integrity module status:

- AlwaysStrong v1.0.1 is installed and enabled.
- Zygisk Next v1.4.2 is enabled.
- LSPosed v2.1.0 (7769) is enabled.
- No keybox contents were printed or committed.

Evidence:

- `evidence/plan-activation-20260705/play-integrity-spic-after-request.png`
- `evidence/plan-activation-20260705/play-integrity-spic-request-output.txt`
- `evidence/plan-activation-20260705/play-integrity-nikolas-after-confirm.png`
- `evidence/plan-activation-20260705/play-integrity-nikolas-confirm-output.txt`
- `evidence/plan-activation-20260705/integrity-stack-summary.txt`

## Next Work

1. Do not enable Hybrid Mount Lite globally again until the WiFi HAL/system_server failure is isolated.
2. If Hybrid Mount is still desired for `adguardcert`, test Nano or a stricter adguardcert-only config with all other system-path modules disabled first.
3. Complete Google account recovery if the device continues to log `BadAuthentication` or `UNAUTHENTICATED`.
4. For STRONG, only test one reversible keybox/attestation change at a time, with Play Integrity cooldowns and screenshots after each change.
5. Keep PixelXpert on the no-mount data-app path for Android 17 unless a future upstream package-manager change makes privileged mounting safe again.
