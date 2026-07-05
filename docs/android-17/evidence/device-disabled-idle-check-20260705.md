# Disabled-State Device Idle Check - 2026-07-05

Device: Pixel 7 Pro `cheetah`
Build: Android 17 `CP2A.260605.012`, SDK 37

## Scope

This was a read-only check after the loader and launcher hardening commits. PixelXpert and LSPosed remained disabled. No reboot, zygote restart, module enable, Play Integrity request, or PixelXpert activation was performed.

## Facts

- ADB transport remained connected:
  - `2B101FDH300NV3 device product:cheetah model:Pixel_7_Pro device:cheetah`
- `sys.boot_completed=1`
- `init.svc.bootanim=stopped`
- Root shell remained available:
  - `uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0`
- Live KSU state remained aligned:
  - `/data/adb/ksud -V`: `ksud 3.2.0`
  - KSU-Next Manager: `versionCode=33129`, `versionName=v3.2.0`
  - Kernel: `Linux localhost 6.1.157+blu-spark #266 SMP PREEMPT Tue Jun 30 19:09:41 WEST 2026 aarch64`

## Module State

Captured with `check-current-module-state-20260705.sh`:

```text
PixelXpert	disabled	version=canary-513 versionCode=513
zygisk_lsposed	disabled	version=v2.1.0 (7769) versionCode=7769
zygisksu	enabled	version=1.4.2 (789-119aaa0-release) versionCode=789
playintegrityfix	enabled	version=v17 versionCode=170000
tricky_store	enabled	version=v6.0.1-282 versionCode=282
rezygisk	disabled	version=v1.0.0 (515-333d423-release) versionCode=515
```

## Crash Evidence

After a bounded idle wait, the newest relevant dropbox entries were still the older known system_server watchdog/anr files:

```text
system_server_pre_watchdog@1783184076537.txt.gz
system_server_pre_watchdog@1783179225869.txt.gz
system_server_watchdog@1783179099073.txt.gz
system_server_pre_watchdog@1783179010948.txt.gz
system_server_anr@1783179007548.txt.gz
system_server_watchdog@1783178964091.txt.gz
system_server_pre_watchdog@1783178874586.txt.gz
system_server_anr@1783178871067.txt.gz
```

No newer relevant `system_server_crash`, `system_server_watchdog`, `system_server_pre_watchdog`, or `system_server_anr` entry appeared during this disabled-state check.

Tombstone listing still showed the existing tombstones only:

```text
tombstone_02
tombstone_02.pb
tombstone_01
tombstone_01.pb
tombstone_00
```

## Interpretation

The current disabled baseline is stable across this short observation window. This does not validate PixelXpert activation or LSPosed scopes; it only confirms that the phone remained usable with the current KSU/Zygisk/PIF/TEESimulator stack while PixelXpert and LSPosed were disabled.
