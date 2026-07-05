# Android 17 Goal-State Recovery Plan - 2026-07-05

Device: Pixel 7 Pro `cheetah`, Android 17 `CP2A.260605.012`, SDK 37.
Root direction: stay on KSU/KSU-Next. Do not migrate to Magisk or APatch to make PixelXpert work.

## Target State

1. Play Integrity is diagnosed to the best achievable verdict on this device. `MEETS_DEVICE_INTEGRITY` is pursued when evidence supports it; `MEETS_STRONG_INTEGRITY` is opportunistic and blocked unless redacted keybox/patch-level evidence supports it.
2. PixelXpert is installed as an Android 17-safe data app, enabled in LSPosed/Vector, and functional across the validated feature scopes.
3. KSU and LSPosed modules that were enabled before this Android 17 recovery session are enabled again and verified.
4. KSU and LSPosed modules are updated from their proper sources:
   - unmodified third-party modules: latest official release/update JSON artifact by default; latest successful upstream GitHub Actions artifact only when provenance is trusted and recorded;
   - forked/patched modules: merge compatible upstream commits into the fork, run GitHub Actions, install the fork CI artifact.

## Evidence Base

Facts:

- PixelXpert's boot-sensitive Android 17 path has already been refactored to default to data-app mode plus `skip_mount`; mounted `/system/priv-app` mode now requires explicit `a17_enable_privapp_mount`.
- PixelXpert's Android 17 default LSPosed scope is self-only unless `a17_enable_default_scopes` exists.
- PixelXpert framework/common/Telecom hooks are blocked by default on Android 17 unless `persist.pixelxpert.a17.unsafe_scopes=1`.
- A CI artifact from this branch is staged on-device with `/data/adb/modules/PixelXpert/disable` and `/data/adb/modules/PixelXpert/skip_mount` present.
- Earlier data-app activation evidence validated PixelXpert self scope and SystemUI scope without new `system_server_*` dropbox entries.
- The unlock crash observed with PixelXpert disabled correlated with third-party LSPosed `system` scopes. Removing `system` scope rows stopped the observed `l53202` SELinux-denial spam during the bounded check.
- The stable root baseline is blu_spark r266 `gs-next`, kernel-side KSU `33129`, KSU-Next userspace/Manager v3.2.0 `33129`, Zygisk Next v1.4.2, PIFork v17, and TEESimulator-RS v6.0.1-282.
- KSU-Next v3.3.0 userspace/Manager `33214` has already produced a UAPI mismatch against blu_spark r266 kernel-side `33129`; do not reinstall it unless the kernel is updated to a matching KSU/KSU-Next side.
- Latest visible release/update checks on 2026-07-05:
  - KSU-Next upstream: v3.3.0, but mismatched with current kernel-side KSU.
  - Zygisk Next: v1.4.2, installed.
  - Play Integrity Fork: v17, installed.
  - TEESimulator-RS: v6.0.1-282, installed.
  - LSPosed update JSON: v2.1.0 / 7769, installed.
  - TrickyStore: v1.4.1, available as a swap-test replacement for TEESimulator-RS, not concurrent.
  - KOWX PlayIntegrityFix: v4.6-inject-s, available as a swap-test replacement for PIFork, not concurrent.

Hypotheses:

- PixelXpert boot stalls with only self LSPosed scope were caused by the mounted priv-app package-scan path, not by self-scope hook execution. Self scope limits LSPosed callbacks; it does not prevent PackageManager from scanning a mounted `/system/priv-app` APK during boot.
- Current `NO_INTEGRITY` or unevaluated Play Integrity state is more likely caused by attestation configuration, keybox validity/revocation, Google throttling, or GMS/Play Store state than by Nohello. Nohello remains a later root-hiding variable, not the first fix.
- Full STRONG may be blocked if the current keybox is revoked or incoherent with Android 17 patch levels. DEVICE is the required fallback target before spending time on STRONG tuning.
- System-scoped LSPosed modules are the highest remaining stability risk and must be restored one at a time.

Open questions:

- The exact module or app that triggered `l53202` access is still unidentified.
- The LSPosed DB needs a compatible sqlite reader or LSPosed/Vector CLI path before exact pre-session module/scope restoration can be automated.
- Kernel options for `cheetah` need a fresh check immediately before any kernel flash. SUSFS is desirable only if the selected kernel explicitly supports Android 17 `CP2A.260605.012`, matches KMI/patch-level requirements, and has coherent KSU/KSU-Next userspace compatibility.
- STRONG status cannot be promised without redacted keybox validity evidence; keybox contents must never be printed or committed.

## Plan

### Phase 0A - Read-Only Baseline And Source Map

No device state changes except read-only inspection.

1. Capture current ADB/root state, module inventory, LSPosed DB backup, newest tombstones, newest `/data/system/dropbox/system_server_*`, GMS/Play Store versions, current Play Integrity checker package/source, and current kernel/KSU versions.
2. Preserve a redacted Play Integrity baseline. Do not print or save keybox contents.
3. Prefer host-side or already-present tooling for LSPosed DB inspection. If the DB cannot be read without staging tooling, stop Phase 0A with that blocker and continue only in Phase 0B.
4. Classify every installed module into one of:
   - current core root baseline: Zygisk Next, PIFork, TEESimulator-RS, KSU userspace/Manager;
   - alternate provider/test candidate: ReZygisk, NeoZygisk, TrickyStore, KOWX PlayIntegrityFix, Nohello;
   - forked/patched: PixelXpert, `adguardcert`, `Thanox`, and any local LSPosed module fork found in `/home/larsm/projects/android-forks`;
   - unmodified third-party: all remaining KSU modules and LSPosed APK modules.
5. For each module, record installed version, enabled/disabled state, update JSON, upstream repo, latest release, latest trusted GitHub Actions artifact availability, artifact hash, and rollback command.
6. Determine the "enabled before this session" set from evidence/backups, not from current `disable` markers. Do not assume intentionally disabled modules such as YouTube Morphe helper modules should be enabled.

Exit gate:

- A committed or staged inventory report exists under `docs/android-17/evidence/`.
- Rollback commands are known for KSU modules, LSPosed DB state, PixelXpert app install, and root-core changes.
- No newer `system_server_crash`, `system_server_watchdog`, `system_server_pre_watchdog`, or `system_server_anr` appears while PixelXpert and LSPosed remain disabled.

### Phase 0B - Controlled Tooling Prep

Run this only if Phase 0A cannot extract required inventory with read-only host/current-device tooling.

1. Stage only the minimum tooling required, such as a compatible sqlite binary, under a deterministic root-owned path.
2. Record source URL, version, laptop hash, device hash, owner, mode, and SELinux label.
3. Create a removal/rollback command before using the tool.
4. Use the staged tool only for schema/module/scope extraction.
5. Remove the staged tool after inventory unless it is explicitly documented as needed for the next phase.

Exit gate:

- Tooling hash and removal command are recorded under `docs/android-17/evidence/`.
- LSPosed DB extraction either succeeds or the blocker is documented without enabling LSPosed.

### Phase 1 - Root Core And Play Integrity, PixelXpert Still Disabled

Goal: diagnose the highest achievable verdict without LSPosed/PixelXpert variables. DEVICE is a target only if the evidence supports it; STRONG is opportunistic and depends on redacted keybox and patch-level validity.

1. Keep blu_spark r266 plus KSU-Next userspace/Manager v3.2.0 unless a newer `cheetah` Android 17 kernel explicitly includes matching KSU/KSU-Next kernel-side support. Do not update KSU-Next Manager to v3.3.0 on r266.
2. Keep only one Zygisk provider enabled. Current default is Zygisk Next v1.4.2. Do not enable ReZygisk or NeoZygisk concurrently.
3. Confirm provider-specific expected injection with process maps before every Play Integrity tuning branch. For the current PIFork/Zygisk Next path, `com.google.android.gms.unstable` and `com.android.vending` evidence is sufficient when documentation or prior evidence says main `com.google.android.gms` mapping is not expected.
4. Use one Play Integrity checker from Play Store plus Play Store developer integrity check. Run sparingly: after each change, reboot or restart only as needed, idle 5-10 minutes, run one check, then stop.
5. Test one variable at a time:
   - current PIFork v17 plus TEESimulator-RS v6.0.1-282 config;
   - PIFork generated/autopif4 profile;
   - TEESimulator-RS `target.txt` minimal targets and suffix modes;
   - TEESimulator-RS `security_patch.txt` absent/default, generated, then coherent `2026-06-05` family values if needed;
   - redacted keybox validity/chain class using a checker that does not expose key material.
6. If TEESimulator-RS cannot produce DEVICE after clean injection and coherent config, swap to official TrickyStore v1.4.1 with the same minimal target discipline. Do not run TrickyStore and TEESimulator-RS together.
7. If PIFork cannot produce DEVICE after keystore-layer tests, swap PIFork to KOWX PlayIntegrityFix v4.6-inject-s with conservative toggles. Do not run both PIF modules together.
8. Nohello is tested only after the above if logs or verdict behavior point to app/root detection rather than attestation mismatch.

Exit gate:

- DEVICE or STRONG is reached, or the plan records a clear blocker such as revoked/invalid keybox.
- The successful stack has process-map evidence, module version hashes, config hashes with secrets redacted, and a rollback script.
- PixelXpert and LSPosed remained disabled during Play Integrity root-cause work.

### Phase 2 - PixelXpert Data-App Activation

Goal: PixelXpert functional without restoring high-risk framework/system scopes.

1. Install the latest successful GitHub Actions artifact for this branch as data app. Keep `/data/adb/modules/PixelXpert/disable` and `skip_mount` present.
2. Before enabling LSPosed/Vector, back up its DB including WAL/SHM handling, disable all non-PixelXpert LSPosed modules or module states for this phase, verify zero `system` scope rows, and verify PixelXpert's module path resolves to the installed `/data/app/.../base.apk`, not `/system/priv-app/...`.
3. Confirm durable rollback controls before every zygote restart or reboot: LSPosed module disable marker can be created, PixelXpert module `disable` and `skip_mount` are present, `persist.pixelxpert.disable_hooks=1` can be set as an emergency hook kill switch, LSPosed DB backup is verified, and a recovery-side command exists to recreate module disable markers.
4. Enable LSPosed/Vector with no PixelXpert target scopes first. Reboot or restart zygote only after rollback is staged.
5. Enable PixelXpert self scope only. Launch PixelXpert and verify root/provider functions.
6. Add `com.android.systemui` only. Restart SystemUI first, then perform a full reboot after a clean smoke window.
7. Add package scopes one at a time:
   - `com.google.android.apps.nexuslauncher`;
   - `com.google.android.dialer`;
   - `com.android.settings` / Settings Intelligence if required;
   - KSU / KSU-Next manager packages if required.
8. Keep `android`, `system`, and `com.android.server.telecom` blocked until Android 17 runtime class/signature checks are implemented and reviewed. They require an explicit unsafe opt-in plus a recovery window.

Exit gate:

- PixelXpert app launches, SystemUI features work, Launcher/Dialer/Settings features are smoke-tested, and no new system_server dropbox/tombstone/logcat regression appears across a defined full boot-and-idle window.

### Phase 3 - Restore And Update LSPosed Modules

Goal: restore only the modules/scopes that were enabled before this recovery session, then update them in a separate pass.

1. Restore known pre-session LSPosed APK versions and scopes one at a time first, if their artifacts/backups are available.
2. After the pre-session version is stable, update each LSPosed APK from the latest trusted source:
   - forked local modules: merge compatible upstream, run GitHub Actions, install fork artifact;
   - unmodified modules: latest official release/update JSON artifact by default; GitHub Actions artifact only when pinned to owner repo, protected branch/tag, exact commit SHA, successful trusted workflow, non-PR provenance, recorded hash, and preferably release-signing or reproducible-build evidence.
3. Restore app-only scopes first and verify target app launches.
4. Restore SystemUI-adjacent app scopes next, one module at a time.
5. Restore any prior `system` scope last, one module at a time, with rollback and a full boot-and-idle check after each. The known prior `system` scope packages are:
   - `com.coderstory.toolkit`
   - `com.wmods.wppenhacer`
   - `com.yureitzk.nophotopickerapi`
   - `org.frknkrc44.hma_oss`
   - `ru.buruobtd.xlduivqjb`
6. If `l53202` denial spam or a new system_server dropbox entry returns, leave the last restored system-scoped module disabled and document it as the blocker.

Exit gate:

- All previously enabled LSPosed modules are either restored and verified or explicitly documented as blocked with evidence.

### Phase 4 - Restore And Update KSU Modules

Goal: restore only the pre-session enabled set first, then update modules while disabled in a separate pass.

1. Download candidate artifacts to the laptop only from trusted upstream sources. Do not build locally.
2. Restore known pre-session module versions one at a time first, when backups/artifacts are available, so restore regressions are separated from update regressions.
3. Prefer official releases/update JSON for unmodified third-party modules. GitHub Actions artifacts are acceptable only when pinned to owner repo, protected branch/tag, exact commit SHA, successful trusted workflow, non-PR provenance, recorded hash, and preferably release-signing or reproducible-build evidence.
4. For forked modules:
   - `adguardcert`: merge compatible upstream/base changes into `larsmartens/adguardcert`, run GitHub Actions, install CI artifact.
   - `Thanox`: locate or clone `larsmartens/Thanox`, merge compatible upstream changes, run GitHub Actions, install CI artifact.
   - other local forks found in `/home/larsm/projects/android-forks`: classify and handle the same way.
5. Stage every replacement disabled, hash on laptop and device, back up the live module directory, and generate rollback before enable.
6. Enable in risk order:
   - non-zygisk data/config modules;
   - user services such as tailscaled/rclone;
   - app mount helpers such as rvmm-zygisk-mount and its dependent app module;
   - audio/media modules;
   - Zygisk add-ons such as detach/nohello/thanox last.
7. Do not enable more than one Zygisk provider. ReZygisk and NeoZygisk remain alternatives, not modules to re-enable alongside Zygisk Next.

Exit gate:

- Every previously enabled KSU module is either updated/restored and verified, or documented as intentionally disabled/blocked with rollback.

### Phase 5 - Kernel Recheck

Goal: do not touch the kernel during recovery unless a fresh check proves it is necessary and safer than staying on the current baseline. SUSFS is not a recovery objective.

1. Check blu_spark, Pixel 7 Pro `cheetah` Android 17 builds, KernelSU-Next kernel-side version, KMI, security patch level, and boot image/init_boot rollback.
2. Compare:
   - current blu_spark r266 KSU `33129` without SUSFS;
   - newer blu_spark if it explicitly supports `CP2A.260605.012` and KSU/KSU-Next v3.3.x;
   - KSU+SUSFS kernel options only if they are current for `cheetah`, match KMI/patch level, and have credible user reports.
3. Flash no kernel until stock/current boot and init_boot images are backed up with hashes on laptop and device, `fastboot devices` visibility is tested, exact rollback commands are written, and matching KMI/security patch/KSU UAPI proof is recorded.
4. After any kernel flash, stop all module restoration work until the phone completes a full boot-and-idle window on the same module set as before the flash.

Exit gate:

- Either a kernel update is applied and validated, or the current r266/v3.2.0 pairing is kept with rationale.

## Rollback Strategy

- Primary KSU module rollback: create `/data/adb/modules/<module>/disable`; preserve module directory backups under `/data/adb/pixelxpert-stage/`; per-module rollback scripts must restore previous directory/config, preserve or recreate `disable`, handle `remove` markers, verify hashes after rollback, and document side effects such as APK uninstall or service disable.
- PixelXpert rollback: keep `/data/adb/modules/PixelXpert/disable`; keep `skip_mount`; uninstall data app only if app-level install is bad.
- LSPosed rollback: restore the backed-up `/data/adb/lspd/config/modules_config.db` or delete the last added scope row; checkpoint or remove WAL/SHM sidecars as appropriate, restore owner/mode/SELinux label, verify with sqlite or LSPosed CLI, then restart zygote only after the DB is verified.
- Root-core rollback: disable the new test module first, restore previous module directory and config files, then reboot.
- Kernel rollback: fastboot flash the saved known-good boot/init_boot image before attempting another kernel.

## Verification Standard

No phase is complete until evidence is recorded:

- file hashes for staged and live artifacts;
- module/property/marker state;
- process-map evidence where Zygisk modules are involved;
- newest dropbox and tombstone timestamps before and after;
- targeted logcat for `system_server`, `Watchdog`, `LSPosed`, `Xposed`, `zygisk`, `PIF`, `tricky`, `tee`, and prior crash signatures;
- one real behavior check for every restored module or PixelXpert scope.

A full boot-and-idle window means:

- `sys.boot_completed=1` and `init.svc.bootanim=stopped`;
- same `system_server` PID survives unlock, screen-off/on, and 10-15 minutes idle;
- no new `system_server_crash`, `system_server_watchdog`, `system_server_pre_watchdog`, or `system_server_anr`;
- no new relevant tombstones;
- targeted logcat has no recurrence of the active failure signature;
- if ADB drops, explicitly check `adb devices -l`, `fastboot devices`, and recovery state before continuing.

## Sources Checked

- Local evidence under `docs/android-17/evidence/`.
- PixelXpert upstream repository and releases: `https://github.com/siavash79/PixelXpert`.
- KernelSU installation/module docs: `https://kernelsu.org/guide/installation.html`.
- KernelSU-Next releases: `https://github.com/KernelSU-Next/KernelSU-Next/releases`.
- Zygisk Next releases/update JSON: `https://github.com/Dr-TSNG/ZygiskNext`.
- Play Integrity Fork releases/update JSON: `https://github.com/osm0sis/PlayIntegrityFork`.
- TEESimulator-RS releases/update JSON: `https://github.com/Enginex0/TEESimulator-RS`.
- LSPosed update JSON: `https://lsposed.zip/update.json`.
- Vector/LSPosed Android 17 discussion and Zygisk Next crash issue: `https://github.com/JingMatrix/Vector`.
- TrickyStore releases: `https://github.com/5ec1cff/TrickyStore/releases`.
- KOWX PlayIntegrityFix and Tricky Addon releases: `https://github.com/KOWX712/PlayIntegrityFix/releases`, `https://github.com/KOWX712/Tricky-Addon-Update-Target-List/releases`.
- XDA and 4PDA indexed results captured in `/tmp/px-plan-xda-pi.json`, `/tmp/px-plan-4pda-pi.json`, and `/tmp/px-plan-lsposed-pixelxpert.json`.

Tooling note: Bright Data discover calls failed during this pass with an expired token; Parallel, GitHub API, Perplexity Web, and general web search were used instead.
