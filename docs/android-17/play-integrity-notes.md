# Play Integrity Notes

Date: 2026-07-04

This file records the Play Integrity/root-stack work done during the Android 17 PixelXpert investigation.

## Modules

- KSU-Next:
  - `ksud 3.2.0`
- Zygisk Next:
  - updated to `1.4.2 (789-119aaa0-release)`
  - rollback path: `/data/adb/zygisk-next-update/backup-20260704-151506/rollback_restore_zygisk_next.sh`
- Play Integrity Fork:
  - `v17`
- TEESimulator-RS / Tricky Store:
  - `v6.0.1-282`

## Config Changes

The Tricky Store target list was reduced from a very broad list to:

```text
com.google.android.gms
com.google.android.gsf
com.android.vending
com.henrikherzig.playintegritychecker
gr.nikolasspyr.integritycheck
io.github.vvb2060.keyattestation
```

`security_patch.txt` was changed to:

```text
all=2026-06-05

[com.google.android.gms]
system=no
```

Rollback paths:

- `/data/adb/tricky_store/backups/play-integrity-opt-20260704-152235/rollback_restore_tricky_store_config.sh`
- `/data/adb/tricky_store/backups/teesim-security-patch-20260704-152707/rollback_restore_security_patch.sh`

## Result

Simple Play Integrity Checker returned:

```text
Device recognition verdict
NO_INTEGRITY
```

This was observed after:

- updating Zygisk Next
- rebooting
- force-stopping Play services / Play Store through PIF `killpi.sh`
- clearing only the checker app data
- running a fresh checker request with the checker in focus

## Evidence

TEESimulator logs showed it was active for Play Integrity and key attestation paths, for example:

```text
TEESimulator: Generating software key for integrity.api.key.alias...
TEESimulator: Using EC keybox keybox.xml
TEESimulator: NativeCertGen: generated key pair successfully (4 certs)
Finsky: Integrity key attestation record generated successfully.
Finsky: requestIntegrityToken() finished for com.henrikherzig.playintegritychecker.
```

Latest current-state evidence also shows TEESimulator activity near unlock:

```text
TEESimulator: No cached chain ... Performing live patch as a fallback.
TEESimulator: Successfully rebuilt a valid, patched certificate chain for UID 10129.
TEESimulator: StrongBox op limit reached for uid=10129
TEESimulator: DeadSystemException: The system died; earlier logs will point to the root cause
```

## Preliminary Assessment

`NO_INTEGRITY` is not fixed. Since TEESimulator is active and generating keybox-backed software keys, the remaining blocker may be server-side rejection of the active keybox/profile, an Android 17 incompatibility, a bad PIF profile for this build, or root-stack side effects.

Do not print or commit `keybox.xml`. Only the keybox SHA256 hash is recorded in the evidence snapshot.

The current unlock crash/restart issue should be stabilized before more Play Integrity changes are attempted.
