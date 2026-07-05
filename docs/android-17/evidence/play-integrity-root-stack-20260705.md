# Play Integrity Root Stack Evidence - 2026-07-05

## Current Stable State

- PixelXpert module: disabled.
- LSPosed module: disabled.
- Nohello: disabled.
- ReZygisk: installed but disabled.
- NeoZygisk: installed under module id `zygisksu`, but disabled after a system_server/zygote startup failure during manual activation.
- Play Integrity Fork v17: installed and enabled, but no active Zygisk provider is currently running.
- TEESimulator-RS v6.0.1-282: installed and enabled.
- After disabling the active Zygisk provider processes and restarting zygote, the device idled for 75 seconds with `system_server` running and no new tombstones observed.

## Baseline And Test Results

- Initial Play Integrity state before this work: no integrity verdicts.
- After manually starting ReZygisk and restarting zygote:
  - The checker returned only `MEETS_BASIC_INTEGRITY`.
  - Raw response showed `sdkVersion: 37`, `appRecognitionVerdict: PLAY_RECOGNIZED`, `appLicensingVerdict: LICENSED`, and `playProtectVerdict: POSSIBLE_RISK`.
  - `deviceRecognitionVerdict` contained only `MEETS_BASIC_INTEGRITY`.
- Process map check showed no PIF, TEESimulator, Zygisk, or ReZygisk artifacts mapped into:
  - `com.google.android.gms`
  - `com.google.android.gms.unstable`
  - `com.android.vending`
  - `gr.nikolasspyr.integritycheck`
- ReZygisk state confirmed the failure mode:
  - `rezygiskd.64.modules` included `playintegrityfix`
  - `zygote.64` remained `0`
- NeoZygisk v2.3 manual activation started its monitor, but after zygote restart Android framework services stayed unavailable until the NeoZygisk monitor/daemon were killed and the module was disabled.

## Interpretation

- The current Play Integrity blocker is not Nohello.
- The current blocker is that no tested Zygisk provider is cleanly injecting the Android 17 64-bit zygote under this KSU-Next/blu_spark r266 state.
- PIF profile changes are not a useful next variable until Zygisk injection is verified in GMS and Play Store process maps.
- The current PIF profile is a Pixel Canary profile. PIFork documentation states that current Pixel Beta/Canary fingerprints no longer pass DEVICE by themselves and are mainly useful for STRONG setups with a working attestation stack.
- TEESimulator-RS did not show process-map evidence of being loaded into the tested target processes during the ReZygisk trial.

## Rollbacks

- Minimal Play Integrity module isolation rollback:
  - `/data/adb/pixelxpert-stage/play-integrity-minimal-stack-20260705-014815/rollback-restore-modules.sh`
- ReZygisk manual-stage rollback:
  - `/data/adb/pixelxpert-stage/rezygisk-manual-20260705-020130/rollback-remove-rezygisk-restore-zygisksu.sh`
- NeoZygisk manual-stage rollback:
  - `/data/adb/pixelxpert-stage/neozygisk-manual-20260705-021355/rollback-restore-previous-zygisksu-rezygisk.sh`

## Next Safe Steps

1. Resolve the KSU-Next userspace/kernel mismatch before more Zygisk provider testing.
2. Retest a single provider using the normal module installer after the mismatch is resolved.
3. Verify injection with process maps before running Play Integrity again.
4. Only after injection is confirmed, test PIF settings and TEESimulator/TrickyStore choices one at a time.
5. Keep Nohello disabled unless root-hiding evidence shows it is specifically needed.

## References

- PIFork README: <https://github.com/osm0sis/PlayIntegrityFork>
- ReZygisk release v1.0.0: <https://github.com/PerformanC/ReZygisk/releases/tag/v1.0.0>
- NeoZygisk release v2.3: <https://github.com/JingMatrix/NeoZygisk/releases/tag/v2.3>
- KSU-Next release v3.3.0: <https://github.com/KernelSU-Next/KernelSU-Next/releases/tag/v3.3.0>
