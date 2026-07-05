# Fresh Session Prompt

Use this prompt for a new Codex session with access to adb and research tools.

```text
You are working on larsmartens/PixelXpert-fork, branch fix/prefs-startup-watchdog, on a laptop connected by adb to a rooted Pixel 7 Pro running Android 17 build CP2A.260605.012 / SDK 37. The goal is to fully and comprehensively refactor PixelXpert for Android 17 and the current root ecosystem. The preferred root framework is KSU, ideally the most advanced stable KSU-Next path available for this device. SUSFS support is desirable if the selected kernel supports it safely; prior kernel tradeoff was roughly blu_spark KSU+SUSFS versus KSU-Next without SUSFS. Do not migrate the device away from KSU/KSU-Next just to make PixelXpert work. Keep Magisk/APatch compatibility in PixelXpert code where feasible, but treat them as compatibility targets, not the preferred runtime on this phone. Also account for NeoZygisk/Zygisk Next, LSPosed/Vector, HybridMount/meta module compatibility, and very low overhead.

Important current state:
- PixelXpert is currently DISABLED on-device via /data/adb/modules/PixelXpert/disable.
- The latest PixelXpert CI artifact for commit 1cf3ba9b built successfully, but on-device testing still stalled boot even when LSPosed scope was only sh.siava.pixelxpert.
- Therefore do not assume the remaining PixelXpert boot problem is SystemUI/Launcher/Dialer hook scope. Investigate the /system/priv-app/PixelXpert mount/package-scan path, LSPosed/Vector behavior, and Android 17 package manager/system_server interactions.
- KSU-Next Manager was updated to v3.3.0 and blu_spark was updated to r266 gs-next. r266 still reports KernelSU 33129, so userspace is newer than the kernel integration. `ksud module list` works, but `ksud module install` fails with a UAPI mismatch.
- Current Zygisk provider state is intentionally conservative: NeoZygisk v2.3 is installed as zygisksu but disabled, ReZygisk v1.0.0 is installed but disabled, LSPosed is disabled, Nohello is disabled.
- Play Integrity testing reached BASIC-only during a manual ReZygisk start, but process maps showed no PIF/TEESimulator/Zygisk artifacts inside GMS/Play Store/checker. NeoZygisk manual activation broke framework service startup until its monitor/daemon were killed and the module was disabled.
- Do not print or commit keybox contents.
- Root framework preference: stay on KSU/KSU-Next. If researching kernels, compare KSU-Next and KSU+SUSFS options for Pixel 7 Pro/cheetah, including blu_spark if still relevant. Do not switch to Magisk/APatch as a solution unless explicitly asked.

Read these repo files first:
- docs/android-17/README.md
- docs/android-17/evidence/current-state-snapshot-20260704-171859.md
- docs/android-17/evidence/ksu-next-manager-kernel-update-20260705.md
- docs/android-17/evidence/play-integrity-root-stack-20260705.md
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
- Run GitHub Actions against larsmartens/PixelXpert-fork and only test on-device with PixelXpert disabled until the staged activation plan is ready.
- Preserve all relevant reports in docs/android-17/ and use neutral commit messages. Do not mention AI/assistant in commits or docs.
```
