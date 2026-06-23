# PixelXpert A17 device diagnostics
Tue Jun 23 23:37:05 CEST 2026

## Device
- ro.product.model=Pixel 7 Pro
- ro.product.device=cheetah
- ro.build.version.release=17
- ro.build.version.sdk=37
- ro.build.version.sdk_full=37.0
- ro.build.id=CP2A.260605.012
- ro.build.version.security_patch=2026-06-05

## Root & modules
ksud: ksud 3.2.0
magisk: n/a
metamodule: lrwxrwxrwx 1 root root 30 2026-06-22 00:02 /data/adb/metamodule -> /data/adb/modules/hybrid_mount
stale flags:
  none (good)

## Hybrid-Mount
default_mode = "overlay"
disable_umount = false
moduledir = "/data/adb/modules"
mountsource = "KSU"
overlay_mode = "ext4"

[kasumi]
cmdline_value = ""
enable_hidexattr = false
enable_kernel_debug = false
enable_maps_spoof = false
enable_mount_hide = false
enable_statfs_spoof = false
enable_stealth = false
enabled = false
hide_uids = []
lkm_autoload = true
lkm_dir = "/data/adb/modules/hybrid_mount/kasumi_lkm"
lkm_kmi_override = ""
mirror_path = "/dev/kasumi_mirror"
uname_mode = "scoped"

[kasumi.mount_hide]
enabled = false
path_pattern = ""

[kasumi.statfs_spoof]
enabled = false
path = ""
spoof_f_type = 0

[kasumi.uname]
domainname = ""
machine = ""
nodename = ""
release = ""
sysname = ""
version = ""
PixelXpert rule: NOT registered

## SUSFS
usage: ksu_susfs <CMD> [CMD options]
help: ksu_susfs --help <CMD>  (for more details of a specific command)
  Detected kernel: susfs v1.5.2 (ABI: prctl)

  <CMD>:
    add_sus_path </path>
    add_sus_mount <mounted_path>
    add_sus_kstat_statically </path> <ino> <dev> <nlink> <size> <atime> <atime_nsec> <mtime> <mtime_nsec> <ctime> <ctime_nsec> <blocks> <blksize>  (pass 'default' for any field)
    add_sus_kstat </path>
    update_sus_kstat </path>
    update_sus_kstat_full_clone </path>
    add_try_umount </path> <mode>  (mode: 0=no flags, 1=MNT_DETACH)
    set_uname <release> <version>  (pass 'default' for either)
    enable_log <0|1>
    set_bootconfig </path/to/file>
    add_open_redirect </target> </redirect>
    sus_su <0|2|show_working_mode>

cli n/a
NOTE: ensure 'Umount modules by default' is OFF and PixelXpert excluded from try_umount

## priv-app mount
  (no explicit mount line)
  MISSING from /system (mount problem!)
pm path: 
version: 

## LSPosed/Vector activation
DB: /data/adb/lspd/config/modules_config.db

## Hook health (logcat)
(empty = no failures since boot)

## SystemUI hook-target check (MISSING = renamed on this build)
MISSING com.android.systemui.Dependency"
MISSING com.android.systemui.accessibility.hearingaid.AmbientVolumeLayout"
MISSING com.android.systemui.clipboardoverlay.ClipboardOverlayController"
MISSING com.android.systemui.doze.DozeSensors$TriggerSensor"
MISSING com.android.systemui.doze.DozeTriggers"
MISSING com.android.systemui.flashlight.data.repository.FlashlightRepositoryImpl"
MISSING com.android.systemui.globalactions.GlobalActionsDialogLite"
MISSING com.android.systemui.globalactions.GlobalActionsDialogLite$LongPressAction"
MISSING com.android.systemui.globalactions.GlobalActionsDialogLite$PowerOptionsAction"
MISSING com.android.systemui.keyguard.domain.interactor.KeyguardInteractor"
MISSING com.android.systemui.keyguard.ui.binder.KeyguardQuickAffordanceViewBinder"
MISSING com.android.systemui.keyguard.ui.composable.elements.SettingsMenuElementProvider"
MISSING com.android.systemui.keyguard.ui.composable.elements.ShortcutElementProvider"
MISSING com.android.systemui.keyguard.ui.view.DeviceEntryIconView"
MISSING com.android.systemui.keyguard.ui.view.KeyguardQuickAffordanceView"
MISSING com.android.systemui.keyguard.ui.view.layout.sections.AodBurnInSection"
MISSING com.android.systemui.keyguard.ui.view.layout.sections.DefaultNotificationStackScrollLayoutSection"
MISSING com.android.systemui.keyguard.ui.view.layout.sections.DefaultSettingsPopupMenuSection"
MISSING com.android.systemui.keyguard.ui.view.layout.sections.DefaultShortcutsSection"
MISSING com.android.systemui.keyguard.ui.view.layout.sections.SmartspaceSection"
MISSING com.android.systemui.keyguard.ui.viewmodel.DeviceEntryIconViewModel"
MISSING com.android.systemui.navigationbar.gestural.BackPanelController"
MISSING com.android.systemui.navigationbar.gestural.EdgeBackGestureHandler"
MISSING com.android.systemui.navigationbar.gestural.NavigationBarEdgePanel"
MISSING com.android.systemui.power.PowerUI"
MISSING com.android.systemui.privacy.PrivacyItem"
MISSING com.android.systemui.qs.external.CustomTile"
MISSING com.android.systemui.qs.panels.data.repository.QSColumnsRepository"
MISSING com.android.systemui.qs.panels.data.repository.QuickQuickSettingsRowRepository"
MISSING com.android.systemui.qs.panels.ui.compose.PaginatedGridLayout"
MISSING com.android.systemui.qs.panels.ui.compose.infinitegrid.CommonTileKt"
MISSING com.android.systemui.qs.tileimpl.QSFactoryImpl"
MISSING com.android.systemui.qs.tileimpl.QSTileImpl"
MISSING com.android.systemui.qs.tileimpl.QSTileImpl$DrawableIcon"
MISSING com.android.systemui.qs.tiles.FlashlightTile"
MISSING com.android.systemui.qs.tiles.FlashlightTileWithLevel"
MISSING com.android.systemui.scene.ui.view.SceneWindowRootView"
MISSING com.android.systemui.screenshot.ScreenshotPolicyImpl"
MISSING com.android.systemui.screenshot.ScreenshotSoundControllerImpl"
MISSING com.android.systemui.screenshot.TakeScreenshotExecutorImpl"
MISSING com.android.systemui.scrim.ScrimView"
MISSING com.android.systemui.shade.NotificationPanelViewController"
MISSING com.android.systemui.shade.NotificationShadeWindowView"
MISSING com.android.systemui.shade.NotificationShadeWindowViewController"
MISSING com.android.systemui.shade.PulsingGestureListener"
MISSING com.android.systemui.shade.ShadeHeaderController"
MISSING com.android.systemui.shade.ShadeSurfaceImpl"
MISSING com.android.systemui.shade.domain.interactor.ShadeInteractorSceneContainerImpl"
MISSING com.android.systemui.statusbar.KeyguardIndicationController"
MISSING com.android.systemui.statusbar.connectivity.CallbackHandler"
MISSING com.android.systemui.statusbar.notification.collection.NotifCollection"
MISSING com.android.systemui.statusbar.notification.footer.ui.view.FooterView"
MISSING com.android.systemui.statusbar.notification.headsup.HeadsUpManagerImpl"
MISSING com.android.systemui.statusbar.notification.icon.ui.viewmodel.NotificationIconContainerAlwaysOnDisplayViewModel"
MISSING com.android.systemui.statusbar.notification.icon.ui.viewmodel.NotificationIconContainerStatusBarViewModel"
MISSING com.android.systemui.statusbar.notification.row.FooterViewButton"
MISSING com.android.systemui.statusbar.notification.stack.NotificationStackScrollLayout"
MISSING com.android.systemui.statusbar.notification.stack.ViewState"
MISSING com.android.systemui.statusbar.phone.ActivityStarterImpl"
MISSING com.android.systemui.statusbar.phone.CentralSurfacesImpl"
MISSING com.android.systemui.statusbar.phone.KeyguardStatusBarView"
MISSING com.android.systemui.statusbar.phone.NotificationIconContainer"
MISSING com.android.systemui.statusbar.phone.PhoneStatusBarView"
MISSING com.android.systemui.statusbar.phone.PhoneStatusBarViewController"
MISSING com.android.systemui.statusbar.phone.ScrimController"
MISSING com.android.systemui.statusbar.phone.ScrimState"
MISSING com.android.systemui.statusbar.phone.StatusBarIconController$IconManager"
MISSING com.android.systemui.statusbar.phone.StatusBarIconHolder"
MISSING com.android.systemui.statusbar.phone.StatusBarKeyguardViewManager"
MISSING com.android.systemui.statusbar.phone.StatusIconContainer"
MISSING com.android.systemui.statusbar.phone.StatusIconContainer$StatusIconState"
MISSING com.android.systemui.statusbar.phone.SystemUIDialog"
MISSING com.android.systemui.statusbar.phone.SystemUIDialog$Factory"
MISSING com.android.systemui.statusbar.phone.ui.IconManager"
MISSING com.android.systemui.statusbar.phone.ui.StatusBarIconControllerImpl"
MISSING com.android.systemui.statusbar.pipeline.mobile.domain.interactor.MobileIconsInteractorImpl"
MISSING com.android.systemui.statusbar.policy.BatteryControllerImpl"
MISSING com.android.systemui.statusbar.policy.Clock"
MISSING com.android.systemui.statusbar.policy.KeyguardStateControllerImpl"
MISSING com.android.systemui.tuner.TunerServiceImpl"
MISSING com.android.systemui.wallpapers.ImageWallpaper$CanvasEngine"
