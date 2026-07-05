# Fresh Session Prompt

Use this prompt for a new Codex session with access to adb and research tools.

```text
You are working on larsmartens/PixelXpert-fork, branch fix/prefs-startup-watchdog, on a laptop connected by adb to a rooted Pixel 7 Pro running Android 17 build CP2A.260605.012 / SDK 37. The goal is to fully and comprehensively refactor PixelXpert for Android 17 and the current root ecosystem. The preferred root framework is KSU, ideally the most advanced stable KSU-Next path available for this device. SUSFS support is desirable if the selected kernel supports it safely; prior kernel tradeoff was roughly blu_spark KSU+SUSFS versus KSU-Next without SUSFS. Do not migrate the device away from KSU/KSU-Next just to make PixelXpert work. Keep Magisk/APatch compatibility in PixelXpert code where feasible, but treat them as compatibility targets, not the preferred runtime on this phone. Also account for NeoZygisk/Zygisk Next, LSPosed/Vector, HybridMount/meta module compatibility, and very low overhead.

Important current state:
- PixelXpert is installed as a normal data app (`sh.siava.pixelxpert`, `canary-513`) and launches through `.FakeSplashActivityNormalIcon`.
- The PixelXpert KSU module remains disabled via `/data/adb/modules/PixelXpert/disable`, and `skip_mount` remains present. Do not remove this durable rollback marker without a fresh baseline and rollback script.
- PixelXpert is enabled in LSPosed with declared scopes only: `android`, `com.android.settings`, `com.android.systemui`, `com.google.android.apps.nexuslauncher`, `com.google.android.dialer`, `com.rifsxd.ksunext`, and `sh.siava.pixelxpert`.
- There is no LSPosed `system` scope row for PixelXpert. PixelXpert, Settings, Google Dialer, and KSU-Next Manager launched after the final restored-module reboot.
- The leading PixelXpert architecture conclusion is that the `/system/priv-app/PixelXpert` mount/package-scan path is not necessary for the current safe baseline and should remain disabled while Android 17 hooks are refactored.
- KSU-Next Manager was updated to v3.3.0 and blu_spark was updated to r266 gs-next. r266 still reports KernelSU 33129, so live KSU userspace and Manager were aligned back to v3.2.0 to restore normal module install behavior.
- Hybrid Mount is not currently installed as an active module. `/data/adb/hybrid-mount` exists as leftover config only; no active Hybrid/meta module, daemon, or mount was found. The `/data/adb` shell read problem is more consistent with KSU/KSU-Next root profile or SELinux context behavior than Hybrid Mount.
- Current Zygisk/module state: Zygisk Next v1.4.2, LSPosed v2.1.0, AlwaysStrong v1.0.1, Zygisk Detach, NoHello, Unlimited Photos, Tailscaled, rclone, rvmm-zygisk-mount, ViPER4Android RE Fork, and AdGuard cert are enabled. ReZygisk, Thanox, Captive Manager, YouTube Morphe, and the PixelXpert KSU module are disabled.
- Play Integrity is currently BASIC plus DEVICE pass and STRONG fail with AlwaysStrong v1.0.1. The earlier STRONG reading was invalid because the checker labels were present but the icon content descriptions were `Fail`.
- Google Play services still reports `BadAuthentication` / `UNAUTHENTICATED` and account-action-required notifications. Resolve the account/session state before more aggressive Play Integrity tuning.
- Do not hammer Play Integrity checks; use cooldowns and one-variable-at-a-time config changes.
- Do not print or commit keybox contents.
- Root framework preference: stay on KSU/KSU-Next. If researching kernels, compare KSU-Next and KSU+SUSFS options for Pixel 7 Pro/cheetah, including blu_spark if still relevant. Do not switch to Magisk/APatch as a solution unless explicitly asked.

Read these repo files first:
- docs/android-17/README.md
- docs/android-17/final-recovery-outcome-20260705.md
- docs/android-17/play-integrity-hybrid-update-20260705.md
- docs/android-17/evidence/current-state-snapshot-20260704-171859.md
- docs/android-17/evidence/ksu-next-manager-kernel-update-20260705.md
- docs/android-17/evidence/play-integrity-root-stack-20260705.md
- docs/android-17/evidence/ksu-next-alignment-and-zygisknext-20260705.md
- docs/android-17/evidence/hybrid-mount-state-20260705.txt
- docs/android-17/evidence/pixelxpert-post-alwaysstrong-launches-20260705.txt
- docs/android-17/evidence/post-alwaysstrong-module-restore-stability-20260705.txt
- docs/android16-stability.md
- app/src/main/java/sh/siava/pixelxpert/xposed/XPLauncher.java
- app/src/main/java/sh/siava/pixelxpert/xposed/XPrefs.java
- app/src/main/java/sh/siava/pixelxpert/xposed/utils/ExtendedRemotePreferences.java
- app/src/main/java/sh/siava/pixelxpert/service/RootProvider.java
- MagiskModBase/customize.sh
- MagiskModBase/service.sh
- app/src/main/AndroidManifest.xml

Use adb from the laptop, not phone-side agents. Follow these rules:
- Verify root with adb shell su -c id before privileged reads.
- Before risky changes, record boot state, module state, hashes, newest dropbox entries, tombstones, and rollback scripts.
- For boot/crash work, inspect /data/system/dropbox/system_server_crash*, system_server_watchdog*, system_server_pre_watchdog*, and system_server_anr*. Tombstones alone are not enough.
- Treat /data/adb/modules/PixelXpert/disable as the durable rollback marker. Do not remove it until the replacement payload and rollback script are verified.
- Keep install/staging separate from activation/reboot.

Research mandate:
- Use all available research tools in this environment, including parallel.ai, octocode, websearch, pwm, oracle, and any code/documentation search tools.
- Research Android 17 package manager, priv-app, boot scan, SELinux, system_server watchdog, and resource/package ID changes relevant to mounted priv-app modules.
- Research LSPosed/Vector behavior on Android 17, especially system_server/package load callbacks, module scoping, and compatibility with NeoZygisk/Zygisk Next.
- Research KSU/KSU-Next, SUSFS, NeoZygisk/Zygisk Next, HybridMount/meta-module mount behavior, and how mounted priv-app APKs interact with Android 17. Include current Pixel 7 Pro kernel options and the KSU-Next-vs-KSU+SUSFS tradeoff.
- Research safer LSPosed module packaging patterns: data-app module APK, no priv-app mount, split APK/root-service architecture, and root provider alternatives.
- Research PixelXpert upstream and comparable modules for Android 16/17 compatibility approaches.
- Research Play Integrity only after stabilizing unlock crashes; do not conflate it with PixelXpert.

Questions to answer:
1. Why does PixelXpert still stall boot with only self LSPosed scope?
2. Is the /system/priv-app mount necessary for current PixelXpert functionality, or can PixelXpert be a normal app plus root/module helper?
3. Which code paths require privileged/system placement versus root shell or LSPosed scope?
4. Which Android 17 framework/SystemUI/Launcher/Dialer hooks are missing or renamed?
5. What minimal architecture should replace the current boot-sensitive startup path?
6. What staged implementation plan gives a boot-safe path to full PixelXpert functionality?
7. What tests and GitHub Actions should be added so regressions are caught before device flashing?

Expected deliverable:
- A written diagnosis that distinguishes facts, hypotheses, and open questions.
- A concrete implementation plan with phases and rollback strategy.
- Then implement the first safe phase in code.
- Run GitHub Actions against larsmartens/PixelXpert-fork. Do not compile locally.
- Only test new PixelXpert changes on-device through the data-app plus LSPosed path unless a staged activation plan explicitly requires changing the KSU module state.
- Preserve all relevant reports in docs/android-17/ and use neutral commit messages. Do not mention AI/assistant in commits or docs.
```
