# Phase 0A Inventory Report - 2026-07-05

Scope: read-only baseline and source-map collection for `fix/prefs-startup-watchdog`. No Gradle/build, no module enablement, no Play Integrity config change, no reboot, and no LSPosed/PixelXpert activation were performed.

## Raw Evidence

These paths are local-only evidence retained on this laptop. The summary below is the committed record; the raw LSPosed DB backup and live capture files are not intended to be pushed.

- ADB/root and baseline: `phase0a-raw-20260705/phase0a-baseline.txt`
- KSU module inventory and LSPosed candidates: `phase0a-raw-20260705/module-and-lsposed-inventory.txt`
- LSPosed DB backup: `phase0a-raw-20260705/lsposed-db-backup/`
- LSPosed host-side sqlite export: `phase0a-raw-20260705/lsposed-host-sqlite-export.txt`
- LSPosed APK package versions: `phase0a-raw-20260705/lsposed-apk-versions.txt`
- Update JSON fetches and hashes: `phase0a-raw-20260705/update-json/`

## Device Baseline

- Device: Pixel 7 Pro `cheetah`, serial `2B101FDH300NV3`.
- Build: Android 17 `CP2A.260605.012`, SDK 37, fingerprint `google/cheetah/cheetah:17/CP2A.260605.012/15430684:user/release-keys`.
- Boot state at capture: `sys.boot_completed=1`, `init.svc.bootanim=stopped`.
- Root check: `uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0`.
- Kernel: `6.1.157+blu-spark #266`, built Tue Jun 30 2026.
- KSU userspace: `ksud 3.2.0`.
- KSU-Next Manager package: `com.rifsxd.ksunext`, `versionName=v3.2.0`, `versionCode=33129`.

Newest crash artifacts at capture:

- Newest relevant system_server dropbox: `/data/system/dropbox/system_server_pre_watchdog@1783184076537.txt.gz`, timestamp 2026-07-04 18:54.
- Newest tombstone: `tombstone_02`, timestamp 2026-07-04 15:15.
- No relevant system_server dropbox newer than 2026-07-04 18:54 was present while PixelXpert and LSPosed KSU modules were disabled.

## Root-Core State

| Component | Current state | Installed version | Source/update |
| --- | --- | --- | --- |
| KSU-Next Manager/userspace | active | Manager `v3.2.0` / `33129`; `ksud 3.2.0` | Keep paired with blu_spark r266 kernel-side KSU `33129`; do not reinstall v3.3.0 without matching kernel support. |
| Zygisk Next `zygisksu` | enabled | `v1.4.2`, code `789` | Update JSON confirms `v1.4.2`; zip URL is `Dr-TSNG/ZygiskNext` release artifact. |
| Play Integrity Fork `playintegrityfix` | enabled | `v17`, code `170000` | Update JSON confirms `v17`; official `osm0sis/PlayIntegrityFork` release artifact. |
| TEESimulator-RS `tricky_store` | enabled | `v6.0.1-282`, code `282` | Update JSON confirms `v6.0.1-282`; official `Enginex0/TEESimulator-RS` release artifact. |
| LSPosed `zygisk_lsposed` | disabled | `v2.1.0`, code `7769` | Update JSON confirms `v2.1.0`; source `https://lsposed.zip/update.json`. |
| PixelXpert KSU module | disabled, `skip_mount=yes` | `canary-513`, code `513` | Fork CI/update source, not upstream release. Data app package is installed separately. |

Integrity config was not printed. Hash-only redacted baseline:

- `/data/adb/tricky_store/keybox.xml`: SHA-256 `7c329ba071aa8ae03481d59ffc81fdbaface01c22ce33cb43612fe7e48f625ac`, size 13048 bytes.
- `/data/adb/tricky_store/target.txt`: SHA-256 `a936c4ef0bc2f26f36dd6c3181de7ebe39e17f8e77261f9d160112c7f201821c`.
- `/data/adb/tricky_store/security_patch.txt`: SHA-256 `791545dd9f0ff47a79df04552a3515a45776d7333427dbe317d7e673f2261bca`.

Play Integrity checker packages currently installed:

- `gr.nikolasspyr.integritycheck`: `2.2`, code `22`, installer `com.android.vending`.
- `com.henrikherzig.playintegritychecker`: `1.4.0`, code `7`, installer `com.android.vending`.
- `io.github.vvb2060.keyattestation`: `1.8.4`, code `201`, installer `com.android.vending`.

GMS/Play Store current data-app versions:

- Google Play services `com.google.android.gms`: `26.25.31 (260400-934625249)`, code `262531035`, updated 2026-06-24.
- Play Store `com.android.vending`: `52.0.21-31 [0] [PR] 936259332`, code `85202130`, updated 2026-06-30.

## KSU Module Inventory And Classification

| Module | State | Version | Classification | Source status |
| --- | --- | --- | --- | --- |
| `PixelXpert` | disabled, `skip_mount=yes` | `canary-513` | forked/patched | Local repo `PixelXpert-fork`; update JSON points at `larsmartens/pixelxpert-updates` and fork release artifact. |
| `adguardcert` | disabled | `v2.2.0-beta.7` | forked/patched | Local repo `adguardcert`; update JSON confirms same version from `larsmartens/adguardcert`. |
| `zygisk_thanox` | disabled | `8.6-81-4388196` | forked/patched source, local checkout missing | Update JSON points at `larsmartens/Thanox`; no `/home/larsm/projects/android-forks/Thanox` checkout found. |
| `zygisksu` | enabled | `v1.4.2` | current core root baseline | Update JSON confirms installed latest exposed by source. |
| `playintegrityfix` | enabled | `v17` | current core root baseline | Update JSON confirms installed latest exposed by source. |
| `tricky_store` | enabled | `v6.0.1-282` | current core root baseline | TEESimulator-RS, not TrickyStore; update JSON confirms installed latest exposed by source. |
| `rezygisk` | disabled | `v1.0.0` | alternate provider/test candidate | Keep disabled; never enable concurrently with Zygisk Next. |
| `zygisk_nohello` | disabled | `v0.0.7` | alternate provider/test candidate | Keep disabled unless root-hiding evidence points to it. |
| `zygisk_lsposed` | disabled | `v2.1.0` | unmodified third-party root framework | Disabled at KSU layer despite enabled rows in LSPosed DB. |
| `magisk-captive-manager` | disabled | `v2.1.4` | unmodified third-party | Update JSON confirms installed latest exposed by source. |
| `magisk-tailscaled` | disabled | `v2.0.0.1` | unmodified third-party | Update JSON confirms installed latest exposed by source. |
| `rclone` | disabled | `v1.74.3` | unmodified third-party | Update JSON confirms installed latest exposed by source. |
| `rvmm-zygisk-mount` | disabled | `v9` | unmodified third-party | Update JSON confirms installed latest exposed by source. |
| `unlimitedphotos` | disabled | `v2` installed; update JSON `v3` | unmodified third-party | Update available by update JSON; do not enable/update in Phase 0A. |
| `youtube-morphe-jhc` | disabled | `v20.51.39 (patches 1.31.0.mpp)` installed; update JSON patches `1.33.0.mpp` | unmodified third-party, dependent helper | Description says keep disabled; mounting handled by `rvmm-zygisk-mount`. |
| `zygisk-detach` | disabled | `v1.23.1` | unmodified third-party | Update JSON confirms installed latest exposed by source. |
| `ViPER4Android-RE-Fork` | disabled | `8.0` | unmodified third-party | No update JSON in module.prop; source/latest unresolved in Phase 0A. |

## LSPosed DB State

Live DB files were copied read-only to the host:

- `modules_config.db`: SHA-256 `8c487b84afcfb208a80bb9f9bcbaa8eef62ac0da9281b87048ba7e61c1e06a48`
- `modules_config.db-wal.live`: SHA-256 `cab6ff4667d1e7b5fe9d75d623077acde61fb191a66b03acd107a01d70939470`
- `modules_config.db-shm.live`: SHA-256 `3da1a66cbd1c372b15328f3f9ef68bf1730311eb5c75afbc48b128d8787a269c`

On-device sqlite was not found in the checked paths, but host `/usr/bin/sqlite3` successfully read the copied DB and exported the schema/module/scope tables. Fresh live WAL/SHM sidecars were preserved under `.live` filenames so host sqlite will not auto-manage them. No Phase 0B tooling is required for read-only DB extraction. Future in-place LSPosed DB modification still needs controlled tooling prep or a verified host-side push/restore workflow before Phase 2/3.

Current DB modules with `enabled=1`:

- `at.gv.oe.idaustriabypass` `1.0.0`: scope `at.gv.oe.app`.
- `com.coderstory.toolkit` `4.9`: enabled, currently no scope row after system-scope isolation.
- `com.fankes.apperrorstracking` `1.5`: enabled, currently no scope row after system-scope isolation.
- `com.kieronquinn.app.classicpowermenu` `1.9.3`: scope `com.android.systemui`.
- `com.wmods.wppenhacer` `1.5.4-DEV (E75DCBA)`: scope `com.whatsapp`.
- `com.yureitzk.nophotopickerapi` `0.4`: enabled, currently no scope row after system-scope isolation.
- `eu.hxreborn.amznkiller` `2.3.2`: enabled, no scope row.
- `eu.hxreborn.discoveradsfilter` `1.2.0`: scope `com.google.android.googlequicksearchbox`.
- `eu.hxreborn.remembermysort` `3.0.0`: scope `com.google.android.documentsui`.
- `eu.rafareborn.biometricbypass` `2.0.1`: enabled, no scope row.
- `io.github.vvb2060.callrecording` `1.3`: scope `com.google.android.dialer`.
- `ltd.nextalone.pkginstallerplus` `1.2.3ca0c12`: scope `com.google.android.packageinstaller`.
- `org.frknkrc44.hma_oss` `oss-158`: enabled, currently no scope row after system-scope isolation.
- `org.klab.batteryinfo` `3.1.1`: scopes `com.android.settings`, `com.google.android.settings.intelligence`.
- `ru.buruobtd.xlduivqjb` `12.0.6`: scopes `com.android.externalstorage`, `com.google.android.documentsui`.
- `ru.mike.updatelocker` `1.4.3`: scopes `com.android.vending`, `com.google.android.packageinstaller`.
- `sh.siava.pixelxpert` `canary-513`: scopes `sh.siava.pixelxpert`, `com.android.systemui`.

Current DB modules with `enabled=0`:

- `ccc71.at.free` `3.1.9`.

No `system` scope row exists in the current LSPosed DB export. The previously documented system-scoped packages remain the high-risk restore set and should be restored one at a time only in Phase 3:

- `com.coderstory.toolkit`
- `com.wmods.wppenhacer`
- `com.yureitzk.nophotopickerapi`
- `org.frknkrc44.hma_oss`
- `ru.buruobtd.xlduivqjb`

`com.fankes.apperrorstracking` also appeared in earlier pre-isolation evidence as system-scoped, but it is not listed in the plan's known prior system-scope set. Treat it as unresolved until Phase 3 source evidence is reconciled.

## Local Fork Map

Local fork repositories found under `/home/larsm/projects/android-forks`:

- `PixelXpert-fork`: `origin=https://github.com/larsmartens/PixelXpert-fork.git`, `upstream=https://github.com/siavash79/PixelXpert.git`, current HEAD `4f2f5b238b71c1a3fd9c7dda84d46dc2be02803a`.
- `adguardcert`: `origin=https://github.com/larsmartens/adguardcert.git`, `upstream=https://github.com/AdguardTeam/adguardcert.git`, current HEAD `e38b5ce3c91c52a77f93b83d3c2f76a10911ef4d`.
- `remember-my-sort`: `origin=https://github.com/larsmartens/remember-my-sort.git`, `upstream=https://github.com/hxreborn/remember-my-sort.git`, current HEAD `d356d30eb44ff7a5f95f533ec60903d143a85f94`.
- `amznkiller`: `origin=https://github.com/larsmartens/amznkiller.git`, `upstream=https://github.com/hxreborn/amznkiller.git`, current HEAD `56ebf3a081825c37b5b9d74845b10de254f348e9`.

No local `Thanox` checkout was found under `/home/larsm/projects/android-forks`, even though the installed `zygisk_thanox` update source points at `larsmartens/Thanox`.

## Rollback-Source Notes

- KSU module rollback default: create or preserve `/data/adb/modules/<id>/disable`; never infer enablement from missing/present current markers alone.
- PixelXpert rollback: existing rollback script `/data/adb/pixelxpert-stage/ci-50106ce9-20260705/rollback-restore-pixelxpert.sh`; module currently has both `disable` and `skip_mount`.
- LSPosed DB rollback source: host backup in `phase0a-raw-20260705/lsposed-db-backup/`. A future restore should prefer the verified standalone `modules_config.db` export unless a live-WAL restore is intentionally prepared; restore owner `root:root`, mode `600`, label `u:object_r:system_file:s0`, then verify with sqlite before any zygote restart.
- Root-core rollback references from prior evidence remain valid: KSU userspace/Manager v3.3.0 rollback scripts are present under `/data/adb/pixelxpert-stage/ksud-align-3-2-0-20260705-113736/` and `/data/adb/pixelxpert-stage/ksunext-manager-downgrade-20260705-113856/`; Zygisk Next disable rollback path is `/data/adb/pixelxpert-stage/zygisknext-enable-20260705-114406/rollback-disable-zygisknext.sh`.
- Source rollback for forked modules should be to the exact fork CI/release artifact recorded in the corresponding evidence file, not to upstream vanilla releases.

## Blockers And Phase Boundaries

- No Phase 0A blocker for LSPosed DB read-only extraction: host sqlite successfully exported modules, states, and scopes from the read-only backup.
- Controlled tooling prep is still required before any on-device LSPosed DB write workflow unless a verified host-side DB edit/push/label/checkpoint flow is prepared in Phase 0B or later.
- The complete KSU "enabled before this session" set is not recoverable from current `disable` markers alone. It must be reconstructed from prior evidence/backups and MMRL/config history before Phase 4. Current state only proves `zygisksu`, `playintegrityfix`, and `tricky_store` are enabled now.
- `Thanox` fork source is referenced by update JSON but no local checkout was found in `/home/larsm/projects/android-forks`; update/merge work is blocked until the trusted fork source is located or cloned.
- `ViPER4Android-RE-Fork` has no update JSON in `module.prop`; trusted source/latest artifact remains unresolved.
- Phase 1 was not started.
