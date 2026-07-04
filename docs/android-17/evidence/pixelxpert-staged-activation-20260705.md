# PixelXpert Android 17 Staged Activation - 2026-07-05

Device: Pixel 7 Pro `cheetah`
Build: Android 17 `CP2A.260605.012`, SDK 37
Branch head tested: `499b5a38f147a4371e650a42bf9ab1a25d769bc4`
GitHub Actions run: <https://github.com/larsmartens/PixelXpert-fork/actions/runs/28721984741>

## Artifact

- Source: `PixelXpert-zip-integrity` artifact from Canary CI run `28721984741`.
- Zip hash: `c52f08a53f45c84937bd60f73cc94ef6f4aab512d767b936d77e80677ae496a6`.
- Staged APK hash on-device: `b3d6c2ec10429da508208d85ebfca8650ed07d4e5051008e20c3eded14690e6a`.
- Package installed as a data app:
  `/data/app/~~gdZnIWR3H5bBjMKi-E5ZCg==/sh.siava.pixelxpert-oDshj4ZC89XmHRjXeOZf-Q==/base.apk`
- Installed package version: `canary-513`, `versionCode=513`, `targetSdk=36`.

## Deployment Facts

- PixelXpert's KSU module remained durably disabled with `/data/adb/modules/PixelXpert/disable`.
- Android 17 mount safety marker `/data/adb/modules/PixelXpert/skip_mount` was present.
- The Android 17 priv-app opt-in marker was absent: `a17_enable_privapp_mount` missing.
- The Android 17 broader default-scope opt-in marker was absent: `a17_enable_default_scopes` missing.
- Direct `pm install` from `/data/adb/modules/PixelXpert/.../PixelXpert.apk` failed because PackageManager could not read `adb_data_file` context. The successful path copied the APK to `/data/local/tmp/PixelXpert-install-28721984741.apk`, labeled `shell_data_file`, then installed it.

## LSPosed Scope State

Self-scope activation:

```text
sh.siava.pixelxpert|sh.siava.pixelxpert|0
```

SystemUI-only activation:

```text
sh.siava.pixelxpert|com.android.systemui|0
sh.siava.pixelxpert|sh.siava.pixelxpert|0
```

No `system` scope rows existed after activation.

## Verification

- PixelXpert launched cold as `sh.siava.pixelxpert/.ui.activities.SettingsActivity` in 812 ms.
- PixelXpert stayed in focus for a three-minute observation window with process PID `3866`.
- SystemUI scope was added, then SystemUI was restarted.
- SystemUI came back as PID `4632` and stayed on that PID through the observation window.
- `system_server` stayed on PID `16555` throughout both self-scope and SystemUI-scope windows.
- Latest relevant dropbox entry remained the old 2026-07-04 entry:
  `/data/system/dropbox/system_server_pre_watchdog@1783184076537.txt.gz`.
- No new tombstones appeared.
- Targeted logcat showed no `l53202`, no `LSPosedFramework: (system)`, and no `system_server_watchdog` or `system_server_pre_watchdog` recurrence.

## Rollback

Rollback staged data-app/self-scope deployment:

```sh
adb shell su -c '/system/bin/sh /data/adb/pixelxpert-stage/data-app-self-scope-20260705-010022/rollback-pixelxpert-data-app-self-scope.sh'
```

Rollback only the SystemUI scope step:

```sh
adb shell su -c '/system/bin/sh /data/adb/pixelxpert-stage/systemui-scope-20260705-010708/rollback-pixelxpert-systemui-scope.sh'
```

## Open Questions

- This validates data-app packaging, self-scope, and SystemUI scope only. Launcher, Dialer, Phone, Settings, and root-manager scopes remain intentionally disabled.
- PixelXpert has not been tested through a full reboot with the module enabled. The KSU module still has the durable `disable` marker.
- Current Play Integrity status remains out of scope until the root stack remains stable across longer normal use.
