# Android 17 Device Class Presence Evidence - 2026-07-05

Device: Pixel 7 Pro `cheetah`
Build: Android 17 `CP2A.260605.012`, SDK 37
State: PixelXpert disabled, LSPosed disabled, read-only APK/JAR pull over adb

## Scope

This is a static class and method-string check against the live device artifacts. It does not enable PixelXpert, LSPosed, or any additional scopes.

Artifacts inspected locally under `/tmp/px-a17-apks`:

- `/system_ext/priv-app/NexusLauncherRelease/NexusLauncherRelease.apk`
- `/system_ext/priv-app/SystemUIGoogle/SystemUIGoogle.apk`
- `/system_ext/priv-app/SettingsGoogle/SettingsGoogle.apk`
- live `com.google.android.dialer` base APK
- `/system/framework/services.jar`
- `/system/framework/framework.jar`
- `/apex/com.android.telephonycore/javalib/service-telecom.jar`

The local machine did not have a dex disassembler installed, so this pass used `unzip -p 'classes*.dex' | strings -a`. This is sufficient for descriptor and method-name presence, but not for signature-level verification.

## Facts

Launcher taskbar descriptors and the two method names used by `TaskbarActivator` are present in the live Android 17 Launcher APK:

- `com.android.launcher3.taskbar.TaskbarActivityContext`
- `com.android.launcher3.taskbar.TaskbarRecentAppsController`
- `com.android.launcher3.taskbar.TaskbarLauncherStateController`
- `com.android.launcher3.deviceprofile.TaskbarProfile`
- `com.android.launcher3.deviceprofile.TaskbarConfiguration`
- `com.android.launcher3.display.LauncherDisplayInfo`
- `com.android.launcher3.taskbar.navbutton.AbstractNavButtonLayoutter`
- `com.android.launcher3.taskbar.FallbackTaskbarUIController`
- `com.android.launcher3.taskbar.overlay.TaskbarOverlayDragLayer`
- `com.android.launcher3.taskbar.KeyboardQuickSwitchController`
- `com.android.launcher3.taskbar.TaskbarView`
- `com.android.quickstep.TopTaskTracker`
- `setCanShowRecentApps`
- `reloadRecentTasksIfNeeded`

SystemUI evidence is mixed:

- Present: `com.android.systemui.shade.NotificationPanelViewController`
- Present: `com.android.systemui.shade.ShadeSurfaceImpl`
- Missing: `com.android.systemui.shade.domain.interactor.ShadeInteractorSceneContainerImpl`
- Present: `com.android.systemui.statusbar.phone.CentralSurfacesImpl`
- Present: `com.android.systemui.statusbar.phone.PhoneStatusBarView`
- Present: `com.android.systemui.keyguard.ui.view.layout.sections.DefaultShortcutsSection`
- Present: `androidx.compose.material3.IconKt`
- Present: `kotlinx.coroutines.flow.ReadonlyStateFlow`

Settings targets checked for the Android 17 manual-scope path are present:

- `com.android.settings.homepage.TopLevelSettings`
- `com.android.settings.widget.HomepagePreference`
- `com.android.settings.applications.ClonedAppsPreferenceController`
- `com.android.settings.applications.AppStateClonedAppsBridge`

The Telecom server target is split into the TelephonyCore APEX on this build:

- `com.android.server.telecom.InCallController` was not found in `/system/framework/services.jar`.
- It was found in `/apex/com.android.telephonycore/javalib/service-telecom.jar`.
- `onCallStateChanged` method strings were also present in `service-telecom.jar`.

Framework targets checked in `services.jar` remain present:

- `com.android.server.policy.PhoneWindowManager`
- `com.android.server.wm.DisplayRotation`
- `com.android.server.power.PowerManagerService`
- `com.android.server.power.FaceDownDetector`
- `com.android.server.display.DisplayPowerController`
- `com.android.server.display.DisplayManagerService`

## Interpretation

The current build does not prove that Launcher taskbar class names are broken. It does prove that relying on unchecked method discovery is still unsafe: a Launcher APK update or R8 rename would currently turn a feature mismatch into package-load failure. `TaskbarActivator` should therefore fail closed when optional taskbar methods are missing.

The SystemUI result confirms active Android 17 shade/scene churn. Existing fallback logic that references `ShadeSurfaceImpl` is relevant for this build, while the `ShadeInteractorSceneContainerImpl` path should be treated as a build-specific fallback, not a guaranteed Android 17 target.

The Telecom result supports keeping Telecom disabled by default on Android 17, but also shows that absence from `services.jar` alone is not proof of class removal. Future Telecom validation must include APEX split jars.

## Open Questions

- Method signatures and parameter ordering still need dex-level or runtime reflection validation before enabling affected scopes.
- SystemUI shade and keyguard paths need feature-by-feature validation after the data-app/self-scope baseline is stable.
- Telecom should remain behind the Android 17 unsafe-scope opt-in until the split-jar classloader behavior is verified under LSPosed/Vector.
