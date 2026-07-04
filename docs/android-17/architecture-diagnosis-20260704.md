# Android 17 Architecture Diagnosis

Date: 2026-07-04

Device target: Pixel 7 Pro (`cheetah`), Android 17 build `CP2A.260605.012`, SDK 37.

## Scope

This report separates PixelXpert Android 17 boot safety from the current unlock-time root-stack instability. PixelXpert is still disabled on the test device through `/data/adb/modules/PixelXpert/disable`; activation testing is intentionally deferred.

## Facts

- PixelXpert disabled is confirmed on-device:
  - `/data/adb/modules/PixelXpert/disable`
  - root context: `u:r:ksu:s0`
  - Android SDK: `37`
  - build: `CP2A.260605.012`
- Fresh `system_server_*` dropbox entries still exist while PixelXpert is disabled. Recent logcat continues to show repeated `system_server` SELinux denials reading `l53202`. This supports treating the unlock crash as root-stack or another module interaction until proven otherwise.
- AOSP package-manager boot code scans system partition `priv-app` directories with privileged scan flags before the non-system app scan. See `InitAppsHelper.scanSystemDirs()` and `ScanPartition` in AOSP:
  - https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/services/core/java/com/android/server/pm/InitAppsHelper.java
  - https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/services/core/java/com/android/server/pm/ScanPartition.java
- PixelXpert's current module zip puts the APK at `system/priv-app/PixelXpert/PixelXpert.apk`, and both module scripts previously treated `/system/priv-app/PixelXpert/PixelXpert.apk` as the only valid LSPosed APK path.
- PixelXpert's LSPosed/libxposed hooks do not inherently require the module APK to be a priv-app. LSPosed/Vector modules are normally APKs whose code is loaded by the framework from the configured module APK path.
- PixelXpert does need root for several operations, but those paths already use `libsu` `RootService`, shell commands, or the exported `PixelXpertProxy` service rather than Android privileged-app permissions.
- Upstream PixelXpert remains a mixed Xposed plus Magisk/KSU module and still warns KSU users about module unmount boot loops:
  - https://github.com/siavash79/PixelXpert
  - https://github.com/siavash79/PixelXpert/releases
- KSU-Next is the preferred root family for this device. Current public KSU-Next materials describe Magic Mount/OverlayFS, app profiles, and SuSFS controls; the device already reports `ksud 3.2.0`.
  - https://github.com/KernelSU-Next/KernelSU-Next
  - https://kernelsu-next.github.io/webpage/
- Vector/LSPosed is the current LSPosed-family path for modern Android. Current materials describe Zygisk-based in-memory hooks and Android 17 beta support, while discussions show that Zygisk-provider compatibility can vary and needs logs when modules fail:
  - https://github.com/JingMatrix/Vector
  - https://github.com/JingMatrix/Vector/discussions/395
  - https://github.com/JingMatrix/Vector/discussions/348
- NeoZygisk releases explicitly call out KernelSU/KernelSU-Next support and LSPosed mount cleanup fixes, making it a serious comparison point against Zygisk Next for this device:
  - https://github.com/JingMatrix/NeoZygisk/releases

## Hypotheses

- The remaining PixelXpert boot stall with only self LSPosed scope is most likely outside normal SystemUI/Launcher/Dialer hook loading. The leading PixelXpert-specific suspect is the mounted `/system/priv-app` package-scan path because it runs during package-manager boot even when LSPosed scope is self-only.
- The `No package ID 7f found for resource ID ...` messages in `system_server` are consistent with resource resolution against an app package ID that is not present in the active `AssetManager` context. They are evidence of resource/package loading trouble, but not yet proof that PixelXpert is the source because the latest occurrences also appear while PixelXpert is disabled.
- The current unlock crash is more likely root-stack or another LSPosed/Zygisk module interaction than PixelXpert. The repeated `l53202` SELinux denial and fresh dropbox entries with PixelXpert disabled need their own isolation pass.
- KSU-Next should remain the default root direction. SUSFS is desirable only if the kernel path is proven stable on `cheetah`; it should not drive PixelXpert architecture.

## Open Questions

- Which active root/LSPosed module owns or triggers accesses to `l53202`?
- Do the newest dropbox entries show binder pool depletion, GC pressure, LSPosed/Vector callback failure, TEESimulator activity, or another blocked thread?
- Which Android 17 SystemUI/Launcher/Dialer classes have changed since Android 16 QPR2? This needs a separate class/method audit against the target build jars or device oat/classpath, not guesswork from source names.
- Does Vector on this exact Zygisk provider accept data-app module APK paths without any manager UI regression? It should, but must be verified after the phone is stable.

## Answers

1. Why does PixelXpert still stall boot with only self LSPosed scope?

   Because self-only LSPosed scope only limits LSPosed package callbacks. It does not remove PixelXpert from Android's boot-time package scan when the APK is mounted under `/system/priv-app`. PackageManager still scans the mounted APK as a privileged system package before normal data-app scanning, so a bad mount/resource/package state can affect boot without SystemUI/Launcher/Dialer hooks.

2. Is the `/system/priv-app` mount necessary?

   It is not necessary for the core LSPosed module identity, preference UI, root shell operations, LSPosed DB edits, or the root proxy service. Those can run as a normal installed app plus a root/module helper. It may have been historically useful for early visibility and KSU mount assumptions, but Android 17 makes it the riskiest startup surface.

3. Which paths require privileged/system placement versus root shell or LSPosed scope?

   No reviewed manifest permission requires priv-app placement. Root-dependent operations are already shell/root-service paths: LSPosed DB edits, module file edits, `cmd`/`pm`/`wm` operations, restarts, and MLKit subject extraction from SystemUI through `PixelXpertProxy`. Framework behavior changes require LSPosed scope, not privileged install location.

4. Which Android 17 hooks are missing or renamed?

   Known unsafe areas are framework `system_server`, Telecom, SystemUI Material/Quick Settings, Launcher taskbar/navigation, Dialer recording, and PackageManager hooks. The current safe answer is that Android 17 class/method parity is unproven; broad Android 17 hook loading should stay gated until each package has a class-presence smoke test and targeted feature validation.

5. What minimal architecture should replace the boot-sensitive startup path?

   Use a normal data-app PixelXpert APK as the LSPosed module. Keep a small module directory for `sqlite3`, scripts, properties, optional root helper assets, and rollback markers. On Android 17, mark the module `skip_mount` by default and activate LSPosed with the APK path returned by `pm path sh.siava.pixelxpert`. Require an explicit marker to restore the old priv-app mount.

6. What staged implementation plan is boot-safe?

   Phase 1: data-app default packaging for Android 17, no activation testing while the phone has unrelated crashes.

   Phase 2: stabilize the current root stack with PixelXpert disabled. Inspect fresh dropbox, disable or de-scope other system-scoped LSPosed modules one at a time, and only then revisit Play Integrity.

   Phase 3: install the new PixelXpert zip while keeping `/data/adb/modules/PixelXpert/disable`. Verify the module has `skip_mount`, the APK is installed as a data app, LSPosed DB points to the data-app `base.apk`, and rollback is still the module `disable` marker plus app uninstall.

   Phase 4: enable only self scope. Reboot, wait through a full boot-and-idle window, and compare dropbox/logcat/tombstones.

   Phase 5: enable one target at a time: SystemUI, Launcher, Dialer, then any framework/Telecom path. Each target gets feature-subset gates and class-presence checks.

7. What tests and GitHub Actions should be added?

   Add shell guards for Android 17 `skip_mount` policy and explicit priv-app opt-in. Add zip integrity checks for data-app policy markers and LSPosed path logic. Add unit/static tests for LSPosed DB schema handling, SQL escaping, and actual APK path resolution. Add a generated modpack inventory check so Android 17 denies framework/common/Telecom hooks by default unless an explicit allowlist is updated. Add an emulator or host-side smoke task that verifies `bash -n`, Gradle compile, manifest sanity, and module zip contents before any device flashing.

## First Safe Phase Implemented

- Android 17 now defaults to data-app mode in `customize.sh` and `service.sh` unless `a17_enable_privapp_mount` exists.
- Data-app mode creates `skip_mount`, clears only transient `mount_error`, installs the staged APK through `pm install -r`, and resolves the actual installed APK path with `pm path`.
- LSPosed/Vector activation now stores the resolved APK path instead of assuming `/system/priv-app/PixelXpert/PixelXpert.apk`.
- `RootProvider` now uses `PackageManager` `sourceDir` when enabling LSPosed from the app UI and includes the installed APK path in diagnostics.
- CI now includes a static guard that the Android 17 data-app mount policy remains present.

## Rollback Strategy

- Durable module rollback remains `/data/adb/modules/PixelXpert/disable`.
- Android 17 data-app mode avoids mounting PixelXpert into `/system/priv-app` unless `a17_enable_privapp_mount` is deliberately present.
- If data-app mode breaks app launch but boot remains stable, uninstall only the app package:
  - `pm uninstall sh.siava.pixelxpert`
- If priv-app opt-in is tested later and boot regresses, restore by creating `/data/adb/modules/PixelXpert/disable` from recovery/adb and removing `a17_enable_privapp_mount`.

