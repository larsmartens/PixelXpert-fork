# Android 17 Root-Stack Isolation - 2026-07-05

Device: Pixel 7 Pro `cheetah`
Build: Android 17 `CP2A.260605.012`, SDK 37
Root context: KernelSU/KSU-Next shell, `u:r:ksu:s0`

## Facts

- ADB was connected as `2B101FDH300NV3 device product:cheetah model:Pixel_7_Pro`.
- Root was available: `uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0`.
- PixelXpert remained disabled throughout this check: `/data/adb/modules/PixelXpert/disable` existed before the zygote restart.
- The live PixelXpert module on-device was still the older canary module with no `skip_mount`; it has not been replaced with the Android 17 data-app CI artifact yet.
- Latest pre-change crash evidence was still from 2026-07-04, with newest relevant dropbox entry:
  `/data/system/dropbox/system_server_pre_watchdog@1783184076537.txt.gz`.
- No new tombstone existed after 2026-07-04 15:15 before or after this isolation step.
- Before isolation, LSPosed had these modules scoped into `system`:
  - `com.coderstory.toolkit`
  - `com.fankes.apperrorstracking`
  - `com.wmods.wppenhacer`
  - `com.yureitzk.nophotopickerapi`
  - `org.frknkrc44.hma_oss`
  - `ru.buruobtd.xlduivqjb`
- Before isolation, logcat repeatedly showed `system_server` SELinux denials reading `l53202` on `/data` (`dm-59`) with labels `system_data_root_file` and `media_userdir_file`.
- The `l53202` path was not found by direct path checks or inode scans under `/data`, `/data_mirror`, `/mnt/pass_through`, or `/mnt/runtime`.

## Change

The LSPosed database `/data/adb/lspd/config/modules_config.db` was backed up and only `scope` rows where `app_pkg_name='system'` were removed. App-specific scopes were preserved.

Backup and rollback path:

```text
/data/adb/pixelxpert-stage/root-stack-isolation-20260705-003110/modules_config.db.before
/data/adb/pixelxpert-stage/root-stack-isolation-20260705-003110/rollback-lsposed-system-scope.sh
```

The database was checkpointed from WAL mode, and DB/sidecar labels were set to `u:object_r:system_file:s0`.

## Verification

- Zygote was restarted with PixelXpert still disabled.
- ADB stayed connected for a full three-minute bounded poll after zygote restart.
- The phone was then observed unlocked on Nova Launcher for an additional post-unlock window.
- `system_server` remained on PID `16555` during both the post-restart and post-unlock polls.
- `sys.boot_completed=1` and `init.svc.bootanim=stopped` after restart.
- No newer `system_server_crash`, `system_server_watchdog`, `system_server_pre_watchdog`, or `system_server_anr` files appeared after the restart.
- No newer tombstones appeared.
- Fresh post-restart and post-unlock logcat slices contained no `l53202`, watchdog, or `LSPosedFramework: (system)` matches.
- LSPosed DB summary after isolation showed no `system` scope rows. Remaining scopes were app-specific, including SystemUI, Dialer, Vending, Settings, external storage/DocumentsUI, WhatsApp, Google app, and package installer.

## Hypothesis

The current unlock/root-stack instability is more likely related to third-party LSPosed modules previously scoped into `system` than to PixelXpert, because PixelXpert was disabled, `l53202` denial spam stopped after removing `system` scopes and restarting zygote, and no new `system_server` dropbox entries appeared during the post-restart window.

## Open Questions

- The exact source of `l53202` remains unidentified because the path was not visible through direct path or inode scans.
- The phone survived a bounded post-unlock observation window. A longer real-use idle period is still useful before staging PixelXpert.
- PixelXpert's new Android 17 data-app module artifact has not yet been staged on-device.
- Play Integrity remains out of scope until the root-stack and unlock behavior are stable.
