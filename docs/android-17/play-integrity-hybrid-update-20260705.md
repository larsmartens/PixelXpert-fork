# Play Integrity And Hybrid Mount Update - 2026-07-05

Device: Pixel 7 Pro `cheetah`, Android 17 `CP2A.260605.012`, SDK 37.

## Facts

- Hybrid Mount is not installed as an active KSU module. There is no active `hybrid_mount`, `meta-overlayfs`, `magic_mount`, or `mountify` module in `ksud module list`.
- `/data/adb/hybrid-mount` exists as leftover state and contains rules for `PixelXpert` and `adguardcert`, but no matching daemon process or active mount was found.
- The `/data/adb` shell read problem is not explained by Hybrid Mount. It is consistent with KSU/KSU-Next root profile or SELinux domain behavior for child commands. Running scripts through KSU BusyBox standalone keeps the effective `u:r:ksu:s0` context and can read `/data/adb`.
- PixelXpert remains installed as a normal data app. The KSU module is disabled and `skip_mount` is present.
- PixelXpert remains enabled in LSPosed with declared scopes only. There is no LSPosed `system` scope.
- PixelXpert, Settings, Google Dialer, and KSU Next Manager launched after the final module restore.
- Official TrickyStore v1.4.1 regressed the device from BASIC-only to Fail/Fail/Fail and logged keystore transaction errors.
- KOWX Play Integrity Fix v4.6-inject-s without a keystore module produced BASIC pass only.
- KOWX plus TEESimulator-RS v6.0.1-282 produced Fail/Fail/Fail.
- AlwaysStrong v1.0.1 replaced the standalone PIF/TEE stack and produced BASIC plus DEVICE pass. STRONG still fails.
- After restoring the previously enabled non-conflicting modules, the verdict remained BASIC plus DEVICE pass and STRONG fail.
- Google Play services repeatedly reports `BadAuthentication` / `UNAUTHENTICATED`, and the device shows account action required notifications. This is now a separate account/session issue to resolve manually or with account reauth.
- A new `keystore2` tombstone appeared at `2026-07-05 18:01` during AlwaysStrong/PIF/TEE churn. It has not recurred after the final module restore reboot. No new `system_server_*` dropbox entries appeared.

## Current Root Module State

Enabled:

- `zygisksu` / Zygisk Next v1.4.2
- `zygisk_lsposed` / LSPosed v2.1.0
- `tricky_store` / AlwaysStrong v1.0.1
- `zygisk-detach` v1.23.1
- `zygisk_nohello` v0.0.7
- `unlimitedphotos` v3
- `magisk-tailscaled` v2.0.0.1
- `rclone` v1.74.3
- `rvmm-zygisk-mount` v9
- `ViPER4Android-RE-Fork` v8.0
- `adguardcert` v2.2.0-beta.7

Disabled:

- `PixelXpert` as a KSU mounted module; active as data app plus LSPosed
- `magisk-captive-manager`
- `rezygisk`
- `zygisk_thanox`
- `youtube-morphe-jhc`

## Hypotheses

- Android 17 `keystore2` behavior is incompatible with official TrickyStore v1.4.1 on this build, and TEESimulator-RS only works reliably when paired and configured through AlwaysStrong's patched PlayIntegrityFork integration.
- STRONG remains blocked by keybox validity/revocation, Google account/session state, or Android 17 attestation changes. The current evidence does not justify more blind keybox churn.
- The Google account reauth issue is not the sole Play Integrity cause: BASIC/DEVICE can pass while `BadAuthentication` remains present.
- Hybrid Mount is relevant to old `/system` payload mounting and the previous PixelXpert priv-app design, but not to the observed `su` child-command SELinux denial.

## Rollback

- Restore the pre-AlwaysStrong KOWX/TEESimulator stack:
  `/data/adb/pixelxpert-stage/alwaysstrong-v101-20260705/rollback-restore-pif-tee.sh`
- Restore nonessential module isolation:
  `/data/adb/pixelxpert-stage/play-integrity-nonessential-isolation-20260705-171422/rollback-restore-nonessential-modules.sh`
- Restore PixelXpert declared LSPosed scopes:
  `/data/adb/pixelxpert-stage/pixelxpert-declared-scopes-20260705-165839/rollback-pixelxpert-declared-scopes.sh`

## Evidence

- Hybrid state: `docs/android-17/evidence/hybrid-mount-state-20260705.txt`
- AlwaysStrong action and verdict: `docs/android-17/evidence/play-integrity-20260705-alwaysstrong/`
- Post-module-restore verdict: `docs/android-17/evidence/play-integrity-20260705-after-module-restore/`
- PixelXpert launch checks: `docs/android-17/evidence/pixelxpert-post-alwaysstrong-launches-20260705.txt`
- Stability check: `docs/android-17/evidence/post-alwaysstrong-module-restore-stability-20260705.txt`

## Sources

- KernelSU module guide: `https://kernelsu.org/guide/module.html`
- Hybrid Mount module docs: `https://modules.kernelsu.org/module/hybrid_mount/`
- Hybrid Mount repository: `https://github.com/Hybrid-Mount/meta-hybrid_mount`
- TrickyStore repository and releases: `https://github.com/5ec1cff/TrickyStore`
- KOWX PlayIntegrityFix release: `https://github.com/KOWX712/PlayIntegrityFix/releases/tag/v4.6-inject-s`
- AlwaysStrong repository and release: `https://github.com/evoker0/AlwaysStrong`, `https://github.com/evoker0/AlwaysStrong/releases/tag/v1.0.1`
