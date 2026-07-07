# PixelXpert Zygisk Next Validation - 2026-07-07

## Scope

This report records the 2026-07-07 on-device validation after installing the CI-built PixelXpert APK from GitHub Actions run `28859947051`, commit `9b6af58c1c79953eac7507f61e1629169d84c18f`.

No laptop build was performed. The APK was extracted from the GitHub Actions `PixelXpert.zip` artifact and installed on-device.

## Zygisk Framework

The active Zygisk provider is Zygisk Next through the KernelSU/KSU Next module `zygisksu`, not NeoZygisk.

Observed module state:

- `zygisksu`: Zygisk Next `1.4.2 (789-119aaa0-release)`, `versionCode=789`
- `zygisk_lsposed`: LSPosed `v2.1.0 (7769)`, `versionCode=7769`
- `PixelXpert`: Pixel Xpert `canary-513`, `versionCode=513`
- All three modules had no `disable` marker after validation.

`zn-zygisk-*` process names are Zygisk Next runtime/companion process names in this stack.

## PixelXpert Install

The CI APK hash installed as the user app:

```text
c47a6f8de8e2d5e42842df0d91d8e72c4ba73ad52f59bb9181aea350e2e26f47
```

The existing installed package had a signing mismatch with the CI APK, so the install required:

1. On-device rollback backup of the previous APK, app data, and LSPosed DB.
2. Full uninstall of `sh.siava.pixelxpert`.
3. Fresh install of the CI APK.
4. Restoration of PixelXpert data.
5. LSPosed DB repair for module path, enabled state, and scopes.

Final LSPosed state:

```text
module: sh.siava.pixelxpert -> /data/app/.../sh.siava.pixelxpert-.../base.apk
state: sh.siava.pixelxpert|0|1|0
scope:
  android
  com.android.settings
  com.android.systemui
  com.google.android.apps.nexuslauncher
  com.google.android.dialer
  sh.siava.pixelxpert
```

The PixelXpert KSU module was enabled and its embedded priv-app APK was updated to the same CI APK hash as the installed user app:

```text
c47a6f8de8e2d5e42842df0d91d8e72c4ba73ad52f59bb9181aea350e2e26f47
```

This avoids a stale KSU module APK becoming active on a future full reboot.

## LSPosed Validation

After restarting the LSPosed daemon and zygote, LSPosed logged successful system framework bridge registration:

```text
LSPosedBridge system server context dispatched
LSPosedService sent service to bridge
```

PixelXpert loaded in the expected scoped processes:

- `sh.siava.pixelxpert`
- `com.android.systemui`
- `com.google.android.apps.nexuslauncher`
- `com.android.settings`
- `com.google.android.dialer`

The previous Android 17 `ScreenGestures` failures did not recur in the post-refresh LSPosed log window:

- no `ScreenGestures`
- no `keyguardNotShowing`
- no `isQSExpanded`
- no `Quarantined failing hook`
- no generic `Hook failure`

## Stability Evidence

Two zygote restarts were performed and both completed with:

```text
sys.boot_completed=1
init.svc.bootanim=stopped
```

After the final restart and idle window:

- `/data/system/dropbox` only showed the expected `SYSTEM_RESTART` entry from the intentional zygote restart.
- No new `system_server_crash`, `system_server_watchdog`, `system_server_pre_watchdog`, or `system_server_anr` entries were observed.
- No new tombstone appeared after the validation window; newest tombstone remained from `2026-07-07 08:17`.

Evidence snapshots on the laptop:

- `/home/larsm/pixelxpert-post-install-pre-zygote`
- `/home/larsm/pixelxpert-post-install-post-zygote`
- `/home/larsm/pixelxpert-post-lspd-refresh-post-zygote`

## Rollback Points

On-device rollback paths:

- Previous signed PixelXpert APK/data/LSPosed DB: `/data/adb/rollback/pixelxpert-resign-install-20260707-104407/rollback-current-apk.sh`
- PixelXpert KSU module APK rollback: `/data/adb/rollback/pixelxpert-ksu-apk-20260707-1058/rollback.sh`
- LSPosed framework disable rollback from earlier validation: `/data/adb/rollback/lsposed-framework-20260707-123120/disable-lsposed.sh`

## Remaining Work

This validates framework injection, scoped module loading, and absence of the known `ScreenGestures` Android 17 failure after the patch. It does not represent exhaustive manual validation of every PixelXpert feature toggle.

Next work should cover:

- Full PixelXpert feature-by-feature validation.
- Play Integrity recovery work.
- A full reboot validation once the current root/module stack is considered ready for boot-level testing.
