# PixelXpert CI Artifact Staged Disabled - 2026-07-05

Device: Pixel 7 Pro `cheetah`
Build: Android 17 `CP2A.260605.012`, SDK 37

## Scope

This staged the GitHub Actions artifact from Canary CI run `28738543788` onto the phone while keeping PixelXpert disabled. PixelXpert was not enabled, LSPosed was not enabled, zygote was not restarted, and the phone was not rebooted.

CI run:

- URL: <https://github.com/larsmartens/PixelXpert-fork/actions/runs/28738543788>
- Head SHA: `50106ce97e9a22ce5b4e7b0cab6e7eda2e24c42c`
- Result: success
- Jobs passed:
  - `lint`
  - `assembleRelease`
  - `assembleDebug`
  - `static module guards`
  - `dependency validation`
  - `zip integrity`

## Artifact

- Artifact name: `PixelXpert-zip-integrity`
- Downloaded file: `/tmp/px-final-ci-28738543788/PixelXpert.zip`
- Module zip SHA-256:
  - `cfe6b39765a48f69f3831bc6511327883ebcdb01eb2b4d3797f522014f8b0a66`
- `module.prop`:
  - `id=PixelXpert`
  - `version=canary-513`
  - `versionCode=513`

## Staging

The artifact was pushed to:

- `/data/local/tmp/px-final-ci-28738543788/PixelXpert.zip`

It was staged with:

- `stage-ci-pixelxpert-disabled-20260705.sh`

Live module path after staging:

- `/data/adb/modules/PixelXpert`

Rollback script:

- `/data/adb/pixelxpert-stage/ci-50106ce9-20260705/rollback-restore-pixelxpert.sh`

## Verification

Device-side zip hash:

```text
cfe6b39765a48f69f3831bc6511327883ebcdb01eb2b4d3797f522014f8b0a66  /data/local/tmp/px-final-ci-28738543788/PixelXpert.zip
```

Live APK hash:

```text
fc8fba234f7754ca5425b68e248059872c97b6db9cb11ce9f1fb2df83f86cf3c  /data/adb/modules/PixelXpert/system/priv-app/PixelXpert/PixelXpert.apk
```

The APK hash matches the APK extracted directly from the CI zip on the laptop.

Disabled/data-app-safe markers:

```text
-rw-r--r-- 1 root root 0 2026-07-05 13:07 /data/adb/modules/PixelXpert/disable
-rw-r--r-- 1 root root 0 2026-07-05 13:07 /data/adb/modules/PixelXpert/skip_mount
```

Rollback script:

```text
-rwx------ 1 root root 365 2026-07-05 13:07 /data/adb/pixelxpert-stage/ci-50106ce9-20260705/rollback-restore-pixelxpert.sh
```

Module state after staging:

```text
PixelXpert	disabled	version=canary-513 versionCode=513
zygisk_lsposed	disabled	version=v2.1.0 (7769) versionCode=7769
zygisksu	enabled	version=1.4.2 (789-119aaa0-release) versionCode=789
playintegrityfix	enabled	version=v17 versionCode=170000
tricky_store	enabled	version=v6.0.1-282 versionCode=282
rezygisk	disabled	version=v1.0.0 (515-333d423-release) versionCode=515
```

Crash baseline after staging:

```text
system_server_pre_watchdog@1783184076537.txt.gz
system_server_pre_watchdog@1783179225869.txt.gz
system_server_watchdog@1783179099073.txt.gz
system_server_pre_watchdog@1783179010948.txt.gz
system_server_anr@1783179007548.txt.gz
```

No newer relevant system_server dropbox entry appeared during the staging check.

## Rollback

Run as root:

```sh
/system/bin/sh /data/adb/pixelxpert-stage/ci-50106ce9-20260705/rollback-restore-pixelxpert.sh
```

The rollback script restores the previous `/data/adb/modules/PixelXpert` backup and recreates both `disable` and `skip_mount`.
