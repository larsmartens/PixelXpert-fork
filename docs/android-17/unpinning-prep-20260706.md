# Android 17 TLS Unpinning Preparation - 2026-07-06

Device: Pixel 7 Pro `cheetah`, Android 17 `CP2A.260605.012`, SDK 37.

This note records the selected TLS unpinning path for AdGuard in-app HTTPS filtering on the current KSU-Next / Zygisk Next / LSPosed stack.

## Goal

Keep AdGuard's system/APEX CA module as the default path and add a narrowly scoped LSPosed unpinning option only for apps that still reject AdGuard interception because of certificate pinning or custom TLS behavior.

Do not enable a global unpinning scope. Scope one target app at a time, force-stop only that app, validate AdGuard behavior, then either keep the narrow scope or roll it back.

## Selected Primary

Primary candidate: SSL Killer

- repo: `Xposed-Modules-Repo/com.simo.ssl.killer`
- release: `2-2.0_Beta`, published `2026-06-19`
- APK: `SSLKiller-v2.0beta.apk`
- SHA256: `cf8ef7147c5ff21c8d058e636d9f9e265fdde49e4601c1af2aba4d9fa957d2f1`
- installed package: `com.simo.ssl.killer`
- installed version: `2.0 Beta`, versionCode `2`
- minSdk: `26`
- targetSdk: `36`
- installed time: `2026-07-06 08:19:24 +0200`
- source: https://github.com/Xposed-Modules-Repo/com.simo.ssl.killer
- release: https://github.com/Xposed-Modules-Repo/com.simo.ssl.killer/releases/tag/2-2.0_Beta

Why selected:

- It is the most recent of the reviewed LSPosed unpinning releases.
- Its README documents Java and native hooks, including OpenSSL and BoringSSL coverage.
- The APK ships native hook libraries (`libsslkiller.so`) and Dobby for multiple ABIs.
- It provides a UI for app selection, which matches the per-app AdGuard goal.

Current state:

- Installed and launchable.
- Not enabled in LSPosed.
- No LSPosed scopes were added.
- Rollback is `adb uninstall com.simo.ssl.killer`.

## Fallbacks

TrustMe:

- repo: `kirklin/TrustMe`
- release: `v1.2.0`, published `2026-05-30`
- APK: `TrustMe-v1.2.0-release.apk`
- SHA256: `f20be12bea301b35862d90cef4377fe8f7fce35f43c93e5483a6904b002ac312`
- source: https://github.com/kirklin/TrustMe
- release: https://github.com/kirklin/TrustMe/releases/tag/v1.2.0
- role: fallback when native hooks are not needed and a lower-complexity Java/Conscrypt/Cronet hook set is preferable.

SSLUnpinner:

- repo: `pccr10001/SSLUnpinner`
- release: `e54310af`, published `2026-03-10`; repo pushed `2026-06-25`
- APK: `SSLUnpinner-e54310af.apk`
- SHA256: `c4b211f2e86070529f5d52ff71427d412dc6edb06c81860defead10cec3a2689`
- source: https://github.com/pccr10001/SSLUnpinner
- release: https://github.com/pccr10001/SSLUnpinner/releases/tag/e54310af
- role: Flutter-specific fallback. Its README documents runtime `libflutter.so` patching for TLS verification.

Do not install or enable the fallback modules alongside SSL Killer unless a specific target app needs that coverage and the previous module has been unscoped or removed.

## Activation Procedure

For each target app:

1. Confirm AdGuard HTTPS filtering is enabled for that app in AdGuard App Management.
2. Confirm the app still fails with AdGuard CA alone.
3. Back up LSPosed DB:
   `cp -a /data/adb/lspd/config/modules_config.db* /data/adb/pixelxpert-stage/<change-id>/`
4. Enable `com.simo.ssl.killer` in LSPosed only for the target package.
5. Force-stop the target app, AdGuard, and SSL Killer if required by the module UI.
6. Relaunch AdGuard, then the target app.
7. Validate AdGuard filtering logs and app behavior.
8. Check `logcat`, LSPosed module logs, and `/data/system/dropbox` for crashes.

Rollback:

1. Remove the target app scope from `com.simo.ssl.killer`.
2. Disable `com.simo.ssl.killer` in LSPosed if no other app uses it.
3. Force-stop the target app.
4. If package-level rollback is needed:
   `adb uninstall com.simo.ssl.killer`

## Safety Notes

- Keep unpinning app-scoped. Do not scope Google Play services, Play Store, banking apps, password managers, system_server, SystemUI, or all apps.
- Prefer AdGuard's per-app HTTPS filtering and the Android 17 system/APEX CA module before LSPosed unpinning.
- Native TLS hooks can destabilize apps. Start with one non-critical target app and keep a rollback copy of the LSPosed DB.
- Some apps may still resist interception through app-specific anti-tamper, root detection, native network stacks, QUIC/HTTP3, or server-side certificate transparency checks.
