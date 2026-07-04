# Current A17 State Snapshot
Sat Jul  4 17:18:59 CEST 2026
1783178339

## boot
bootmode=unknown
boot_completed=1
bootanim=stopped
uptime=5492.49 40489.46

## root
uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0
ksud 3.2.0

## modules
-- PixelXpert
id=PixelXpert
name=Pixel Xpert
version=canary-513
versionCode=513
author=Pixel Xpert Team
description=Xposed based module for customizations on Pixel roms. Android 13+
updateJson=https://cdn.jsdelivr.net/gh/larsmartens/pixelxpert-updates@canary/MagiskModuleUpdate_Xposed.json
minMagisk=25000
-rw-r--r-- 1 root root 0 2026-07-04 15:47 /data/adb/modules/PixelXpert/disable
-- zygisksu
id=zygisksu
name=Zygisk Next
version=1.4.2 (789-119aaa0-release)
versionCode=789
author=5ec1cff, Nullptr
description=[✅zygote, Root: ✅KernelSU (33129), ZL] Standalone implementation of Zygisk.
updateJson=https://api.nullptr.icu/android/zygisk-next/static/update.json
-- playintegrityfix
id=playintegrityfix
name=Play Integrity Fork
version=v17
versionCode=170000
author=osm0sis & chiteroman @ xda-developers
description=Fix <A13 Play Integrity DEVICE verdict
updateJson=https://raw.githubusercontent.com/osm0sis/PlayIntegrityFork/main/update.json
-- tricky_store
id=tricky_store
name=TEESimulator-RS
version=v6.0.1-282
versionCode=282
author=JingMatrix, Enginex0
description=Software simulation for Android hardware-backed key pairs with key attestation
updateJson=https://raw.githubusercontent.com/Enginex0/TEESimulator-RS/main/module/update.json

## pixelxpert
-rw-r--r-- 1 root root   0 2026-07-04 15:47 /data/adb/modules/PixelXpert/disable
-rw-r--r-- 1 root root 292 2026-07-04 15:42 /data/adb/modules/PixelXpert/module.prop

## play integrity / teesim config
# Build Fields
MANUFACTURER=Google
MODEL=Pixel 7 Pro
FINGERPRINT=google/cheetah_beta/cheetah:CANARY/ZP11.260515.009/15513807:user/release-keys
BRAND=google
PRODUCT=cheetah_beta
DEVICE=cheetah
RELEASE=CANARY
ID=ZP11.260515.009
INCREMENTAL=15513807
TYPE=user
TAGS=release-keys
SECURITY_PATCH=2026-06-05
DEVICE_INITIAL_SDK_INT=32

# System Properties
*.build.id=ZP11.260515.009
*.security_patch=2026-06-05
*api_level=32

# Advanced Settings
spoofBuild=1
spoofProps=1
spoofProvider=0
spoofSignature=0
spoofVendingFinger=0
spoofVendingSdk=0
verboseLogs=0

# Canary Released: 2026-06-03
# Estimated Expiry: 2026-07-15
-- tricky target
# Minimal Play Integrity attestation targets.
# Keep the list narrow to reduce keystore hook overhead and avoid app-specific breakage.
com.google.android.gms
com.google.android.gsf
com.android.vending
com.henrikherzig.playintegritychecker
gr.nikolasspyr.integritycheck
io.github.vvb2060.keyattestation
-- tricky security patch
all=2026-06-05

[com.google.android.gms]
system=no
-- tricky keybox hash
7c329ba071aa8ae03481d59ffc81fdbaface01c22ce33cb43612fe7e48f625ac  /data/adb/tricky_store/keybox.xml

## recent dropbox
-rw------- 1 system system 20639 2026-07-04 17:18 /data/system/dropbox/system_server_pre_watchdog@1783178323478.txt.gz
-rw------- 1 system system 21069 2026-07-04 17:18 /data/system/dropbox/system_server_anr@1783178303324.txt.gz
-rw------- 1 system system 21585 2026-07-04 17:17 /data/system/dropbox/system_server_watchdog@1783178255409.txt.gz
-rw------- 1 system system 22396 2026-07-04 17:16 /data/system/dropbox/system_server_pre_watchdog@1783178203949.txt.gz
-rw------- 1 system system 21426 2026-07-04 17:16 /data/system/dropbox/system_server_anr@1783178182432.txt.gz
-rw------- 1 system system  2206 2026-07-04 17:15 /data/system/dropbox/data_app_crash@1783178124583.txt
-rw------- 1 system system   821 2026-07-04 15:33 /data/system/dropbox/data_app_crash@1783172021484.txt
-rw------- 1 system system 21645 2026-07-04 15:33 /data/system/dropbox/system_server_pre_watchdog@1783172019367.txt.gz
-rw------- 1 system system  2205 2026-07-04 15:32 /data/system/dropbox/data_app_crash@1783171950866.txt
-rw------- 1 system system   839 2026-07-04 15:32 /data/system/dropbox/data_app_crash@1783171924349.txt
-rw------- 1 system system   840 2026-07-04 15:32 /data/system/dropbox/data_app_crash@1783171921979.txt
-rw------- 1 system system   840 2026-07-04 15:31 /data/system/dropbox/data_app_crash@1783171919373.txt
-rw------- 1 system system   840 2026-07-04 15:31 /data/system/dropbox/data_app_crash@1783171916206.txt
-rw------- 1 system system 20736 2026-07-04 15:23 /data/system/dropbox/system_server_pre_watchdog@1783171421031.txt.gz
-rw------- 1 system system   821 2026-07-04 15:21 /data/system/dropbox/data_app_crash@1783171298768.txt
-rw------- 1 system system  2205 2026-07-04 15:20 /data/system/dropbox/data_app_crash@1783171212006.txt
-rw------- 1 system system   839 2026-07-04 15:19 /data/system/dropbox/data_app_crash@1783171194009.txt
-rw------- 1 system system   840 2026-07-04 15:19 /data/system/dropbox/data_app_crash@1783171191244.txt
-rw------- 1 system system   840 2026-07-04 15:19 /data/system/dropbox/data_app_crash@1783171186825.txt
-rw------- 1 system system   840 2026-07-04 15:19 /data/system/dropbox/data_app_crash@1783171183997.txt
-rw------- 1 system system  5551 2026-07-04 15:16 /data/system/dropbox/SYSTEM_TOMBSTONE@1783170964222.txt.gz
-rw------- 1 system system 12011 2026-07-04 15:16 /data/system/dropbox/SYSTEM_TOMBSTONE_PROTO_WITH_HEADERS@1783170963967.dat
-rw------- 1 system system   840 2026-07-04 15:15 /data/system/dropbox/data_app_crash@1783170905336.txt
-rw------- 1 system system   839 2026-07-04 15:15 /data/system/dropbox/data_app_crash@1783170901644.txt
-rw------- 1 system system   840 2026-07-04 15:14 /data/system/dropbox/data_app_crash@1783170898640.txt
-rw------- 1 system system   839 2026-07-04 15:14 /data/system/dropbox/data_app_crash@1783170894792.txt
-rw------- 1 system system 20361 2026-07-04 15:13 /data/system/dropbox/system_server_anr@1783170836633.txt.gz
-rw------- 1 system system 20521 2026-07-04 14:58 /data/system/dropbox/system_server_anr@1783169901490.txt.gz
-rw------- 1 system system 20999 2026-07-04 10:42 /data/system/dropbox/system_server_pre_watchdog@1783154521386.txt.gz
-rw------- 1 system system   821 2026-07-04 10:41 /data/system/dropbox/data_app_crash@1783154512800.txt
-rw------- 1 system system  2206 2026-07-04 10:40 /data/system/dropbox/data_app_crash@1783154456319.txt
-rw------- 1 system system   839 2026-07-04 10:40 /data/system/dropbox/data_app_crash@1783154441812.txt
-rw------- 1 system system   840 2026-07-04 10:40 /data/system/dropbox/data_app_crash@1783154439430.txt
-rw------- 1 system system   839 2026-07-04 10:40 /data/system/dropbox/data_app_crash@1783154437210.txt
-rw------- 1 system system   840 2026-07-04 10:40 /data/system/dropbox/data_app_crash@1783154434744.txt
-rw------- 1 system system 20738 2026-07-04 09:33 /data/system/dropbox/system_server_pre_watchdog@1783150392126.txt.gz
-rw------- 1 system system   821 2026-07-04 09:33 /data/system/dropbox/data_app_crash@1783150380959.txt
-rw------- 1 system system  2205 2026-07-04 09:31 /data/system/dropbox/data_app_crash@1783150279267.txt
-rw------- 1 system system   839 2026-07-04 09:30 /data/system/dropbox/data_app_crash@1783150244581.txt
-rw------- 1 system system   840 2026-07-04 09:30 /data/system/dropbox/data_app_crash@1783150242027.txt

## recent tombstones
total 6284
-rw-rw-r-- 1 tombstoned system  416967 2026-07-04 15:15 tombstone_02
-rw-rw-r-- 1 tombstoned system  215407 2026-07-04 15:15 tombstone_02.pb
-rw-rw-r-- 1 tombstoned system  500094 2026-07-04 02:27 tombstone_01
-rw-rw-r-- 1 tombstoned system  247706 2026-07-04 02:27 tombstone_01.pb
-rw-rw-r-- 1 tombstoned system  499751 2026-07-04 02:26 tombstone_00
-rw-rw-r-- 1 tombstoned system  247473 2026-07-04 02:26 tombstone_00.pb
-rw-rw-r-- 1 tombstoned system  503907 2026-07-01 00:34 tombstone_07
-rw-rw-r-- 1 tombstoned system  249686 2026-07-01 00:34 tombstone_07.pb
-rw-rw-r-- 1 tombstoned system 1036862 2026-06-29 19:33 tombstone_06
-rw-rw-r-- 1 tombstoned system  593973 2026-06-29 19:33 tombstone_06.pb
-rw-rw-r-- 1 tombstoned system 1205307 2026-06-29 19:33 tombstone_05
-rw-rw-r-- 1 tombstoned system  687968 2026-06-29 19:33 tombstone_05.pb

## recent targeted logcat
07-04 17:18:43.346 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f110025.
07-04 17:18:43.372 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f080065.
07-04 17:18:43.372 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0e0085.
07-04 17:18:43.428 22935 25699 I DropBoxManagerService: add tag=system_server_pre_watchdog isTagEnabled=true flags=0x6
07-04 17:18:43.456 22935 22935 W binder:22935_B: type=1400 audit(0.0:1031107): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:43.456 22935 22935 W binder:22935_B: type=1400 audit(0.0:1031108): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:43.456 22935 22935 W binder:22935_B: type=1400 audit(0.0:1031109): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:43.456 22935 22935 W binder:22935_B: type=1400 audit(0.0:1031110): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:43.460 22935 22935 W binder:22935_B: type=1400 audit(0.0:1031111): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:43.472 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0811ac.
07-04 17:18:43.472 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f1528bf.
07-04 17:18:43.472 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0811b4.
07-04 17:18:43.472 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f1528c0.
07-04 17:18:43.513 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0d0009.
07-04 17:18:43.513 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0f008d.
07-04 17:18:43.513 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0f008d.
07-04 17:18:43.513 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0d0003.
07-04 17:18:43.513 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0f0085.
07-04 17:18:43.513 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0f0085.
07-04 17:18:43.514 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0d0006.
07-04 17:18:43.514 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0f01c6.
07-04 17:18:43.514 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f0f01c6.
07-04 17:18:43.605 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f080633.
07-04 17:18:43.605 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f140c80.
07-04 17:18:43.609 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f080631.
07-04 17:18:43.609 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f140c3a.
07-04 17:18:43.609 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f080635.
07-04 17:18:43.609 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f140dcd.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f080790.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f111378.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f111373.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f08078e.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f111376.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f111371.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f08078c.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f111374.
07-04 17:18:43.742 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f11136f.
07-04 17:18:43.743 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f08078d.
07-04 17:18:43.743 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f111375.
07-04 17:18:43.743 22935 24743 E system_server: No package ID 7f found for resource ID 0x7f111370.
07-04 17:18:44.460 22935 22935 W binder:22935_13: type=1400 audit(0.0:1036059): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:44.460 22935 22935 W binder:22935_13: type=1400 audit(0.0:1036060): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:44.460 22935 22935 W binder:22935_13: type=1400 audit(0.0:1036061): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:44.460 22935 22935 W binder:22935_13: type=1400 audit(0.0:1036062): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:44.464 22935 22935 W binder:22935_13: type=1400 audit(0.0:1036063): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:45.102 25702 25702 I LSPosedFramework: (com.google.android.googlequicksearchbox:googleapp)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,6466-19f2db5ec63-2-1,0,1] v1.2.0 loaded in com.google.android.googlequicksearchbox:googleapp
07-04 17:18:45.480 22935 22935 W binder:22935_4: type=1400 audit(0.0:1039317): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:45.480 22935 22935 W binder:22935_4: type=1400 audit(0.0:1039318): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:45.480 22935 22935 W binder:22935_4: type=1400 audit(0.0:1039319): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:45.484 22935 22935 W binder:22935_4: type=1400 audit(0.0:1039320): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:45.484 22935 22935 W binder:22935_4: type=1400 audit(0.0:1039321): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:45.824 22935 22992 I system_server: Background young concurrent mark compact GC freed 225MB AllocSpace bytes, 1983(40MB) LOS objects, 33% free, 339MB/512MB, paused 30.539ms,16.602ms total 2.679s
07-04 17:18:45.858  4797  7248 I TEESimulator: [TX_ID: 899] createOperation KeyId(8895120951557869491) NOT FOUND for uid=1000. Forwarding to HAL.
07-04 17:18:45.885   552 20463 I keystore2: system/security/keystore2/src/authorization.rs:267 - add_auth_token(challenge=0, userId=5816048348000840859, authId=0, authType=0x1, timestamp=5490614ms)
07-04 17:18:45.904   552 20463 I keystore2: system/security/keystore2/src/authorization.rs:253 - add LockStateNotification { user: AndroidUserId(0), state: DeviceUnlocked { password: Some(Zvec size: 64 [ Sensitive information redacted ]) } } to notification queue
07-04 17:18:45.910   552 25856 I keystore2: system/security/keystore2/src/authorization.rs:255 - process LockStateNotification { user: AndroidUserId(0), state: DeviceUnlocked { password: Some(Zvec size: 64 [ Sensitive information redacted ]) } } from notification queue
07-04 17:18:45.910   552 25856 I keystore2: system/security/keystore2/src/authorization.rs:163 - on_device_unlocked(AndroidUserId(0), password.is_some()=true)
07-04 17:18:45.911   552 25856 I keystore2: system/security/keystore2/src/database.rs:1206 - Setting synchronous=EXTRA
07-04 17:18:45.912   552 25856 I keystore2: system/security/keystore2/src/super_key.rs:1175 - CredentialEncrypted super key for user AndroidUserId(0) is already unlocked.
07-04 17:18:45.925   552 20463 I keystore2: system/security/keystore2/src/authorization.rs:267 - add_auth_token(challenge=0, userId=5816048348000840859, authId=0, authType=0x1, timestamp=5490653ms)
07-04 17:18:45.948   552 20463 I keystore2: system/security/keystore2/src/authorization.rs:267 - add_auth_token(challenge=0, userId=5816048348000840859, authId=0, authType=0x1, timestamp=5490675ms)
07-04 17:18:45.966   552 20463 I keystore2: system/security/keystore2/src/authorization.rs:267 - add_auth_token(challenge=0, userId=5816048348000840859, authId=0, authType=0x1, timestamp=5490695ms)
07-04 17:18:46.230 25702 25702 W LSPosedFramework: (com.google.android.googlequicksearchbox:googleapp)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,6466-19f2db5ec63-2-2,0,1] skipped proc=com.google.android.googlequicksearchbox:googleapp v=301766375 reason=no cache for AGSA v301766375, run Verify from module app lastRemoteWrite=0
07-04 17:18:46.231 25702 25702 W LSPosedFramework: (com.google.android.googlequicksearchbox:googleapp)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,6466-19f2db5ec63-2-3,0,1] no stream method in cache proc=com.google.android.googlequicksearchbox:googleapp reason=no cache for AGSA v301766375, run Verify from module app, open Discover Ads Filter and tap Verify
07-04 17:18:46.232 25702 25702 I LSPosedFramework: (com.google.android.googlequicksearchbox:googleapp)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,6466-19f2db5ec63-2-4,0,1] installed proc=com.google.android.googlequicksearchbox:googleapp agsaV=301766375 hooks=0/1 failed:StreamSliceFilterHook Missing(no cache for AGSA v301766375, run Verify from module app)
07-04 17:18:46.293 25880 25880 I zn-zygisk-companion64: spawning companion for unlimitedphotos
07-04 17:18:46.518 25702 25908 D nativeloader: Load /data/app/~~RPqWUUxyXqbFwJOifbdNKA==/com.google.android.googlequicksearchbox-Dn255FfrdcDAI39Zem6a7Q==/base.apk!/lib/arm64-v8a/libnative_crash_handler_jni.so using class loader ns clns-9 (caller=/data/app/~~RPqWUUxyXqbFwJOifbdNKA==/com.google.android.googlequicksearchbox-Dn255FfrdcDAI39Zem6a7Q==/base.apk!classes3.dex): ok
07-04 17:18:46.613 22935 23948 D FaceProvider/default: Starting watchdog for face
07-04 17:18:46.613 22935 23948 E BiometricScheduler: Current operation is null,no need to start watchdog
07-04 17:18:46.630 25180 25343 V DynamiteModule: Dynamite loader version >= 2, using loadModule2NoCrashUtils
07-04 17:18:46.484 22935 22935 W binder:22935_13: type=1400 audit(0.0:1040562): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:46.484 22935 22935 W binder:22935_13: type=1400 audit(0.0:1040563): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:46.484 22935 22935 W binder:22935_13: type=1400 audit(0.0:1040564): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:46.484 22935 22935 W binder:22935_13: type=1400 audit(0.0:1040565): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:46.484 22935 22935 W binder:22935_13: type=1400 audit(0.0:1040566): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:47.022 22935 22935 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.022 22935 22996 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.022 22935 25276 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.022 22935 23727 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.022 22935 24608 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.023 22935 23156 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.024 22935 23877 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.024 22935 23357 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.024 22935 23948 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.024 22935 25157 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.026 22935 25951 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.026 22935 23736 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.028 22935 22997 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.071 22935 23301 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.125 22935 23265 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.130 22935 23703 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.167 22935 23469 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.184 22935 23702 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.202 22935 25956 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.220 22935 23958 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.220 22935 23392 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.249 22935 25312 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.257 22935 23707 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.289 22935 23900 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.351 22935 25314 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.375 22935 25318 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.379 22935 25961 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.426 22935 23095 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.450 22935 24379 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:47.884 22935 22992 I system_server: Background concurrent mark compact GC freed 295MB AllocSpace bytes, 1828(36MB) LOS objects, 64% free, 180MB/512MB, paused 2.094ms,10.426ms total 2.057s
07-04 17:18:47.885 22935 22935 I system_server: WaitForGcToComplete blocked Alloc on Background for 862.867ms
07-04 17:18:47.885 22935 22996 I system_server: WaitForGcToComplete blocked Alloc on Background for 862.697ms
07-04 17:18:47.886 22935 25276 I system_server: WaitForGcToComplete blocked Alloc on Background for 864.101ms
07-04 17:18:47.886 22935 23727 I system_server: WaitForGcToComplete blocked Alloc on Background for 864.096ms
07-04 17:18:47.884 22935 22935 W binder:22935_E: type=1400 audit(0.0:1041553): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:47.884 22935 22935 W binder:22935_E: type=1400 audit(0.0:1041554): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:47.888 22935 24608 I system_server: WaitForGcToComplete blocked Alloc on Background for 865.350ms
07-04 17:18:47.888 22935 23156 I system_server: WaitForGcToComplete blocked Alloc on Background for 865.428ms
07-04 17:18:47.889 22935 23877 I system_server: WaitForGcToComplete blocked Alloc on Background for 865.411ms
07-04 17:18:47.890 22935 23357 I system_server: WaitForGcToComplete blocked Alloc on Background for 866.338ms
07-04 17:18:47.892 22935 23948 I system_server: WaitForGcToComplete blocked Alloc on Background for 867.634ms
07-04 17:18:47.892 22935 25157 I system_server: WaitForGcToComplete blocked Alloc on Background for 867.584ms
07-04 17:18:47.893 22935 25951 I system_server: WaitForGcToComplete blocked Alloc on Background for 867.413ms
07-04 17:18:47.897 22935 23736 I system_server: WaitForGcToComplete blocked Alloc on Background for 870.446ms
07-04 17:18:47.899 22935 22997 I system_server: WaitForGcToComplete blocked Alloc on Background for 870.881ms
07-04 17:18:47.900 22935 23301 I system_server: WaitForGcToComplete blocked Alloc on Background for 829.255ms
07-04 17:18:47.900 22935 23265 I system_server: WaitForGcToComplete blocked Alloc on Background for 775.284ms
07-04 17:18:47.903 22935 23703 I system_server: WaitForGcToComplete blocked Alloc on Background for 772.503ms
07-04 17:18:47.904 22935 23469 I system_server: WaitForGcToComplete blocked Alloc on Background for 736.098ms
07-04 17:18:47.904 22935 23702 I system_server: WaitForGcToComplete blocked Alloc on Background for 719.434ms
07-04 17:18:47.904 22935 25956 I system_server: WaitForGcToComplete blocked Alloc on Background for 702.413ms
07-04 17:18:47.904 22935 23958 I system_server: WaitForGcToComplete blocked Alloc on Background for 684.251ms
07-04 17:18:47.905 22935 23392 I system_server: WaitForGcToComplete blocked Alloc on Background for 684.285ms
07-04 17:18:47.906 22935 25312 I system_server: WaitForGcToComplete blocked Alloc on Background for 657.667ms
07-04 17:18:47.908 22935 23707 I system_server: WaitForGcToComplete blocked Alloc on Background for 651.431ms
07-04 17:18:47.910 22935 23900 I system_server: WaitForGcToComplete blocked Alloc on Background for 620.482ms
07-04 17:18:47.910 22935 25314 I system_server: WaitForGcToComplete blocked Alloc on Background for 559.098ms
07-04 17:18:47.911 22935 25318 I system_server: WaitForGcToComplete blocked Alloc on Background for 535.228ms
07-04 17:18:47.911 22935 25961 I system_server: WaitForGcToComplete blocked Alloc on Background for 531.504ms
07-04 17:18:47.911 22935 23095 I system_server: WaitForGcToComplete blocked Alloc on Background for 484.546ms
07-04 17:18:47.911 22935 24379 I system_server: WaitForGcToComplete blocked Alloc on Background for 461.235ms
07-04 17:18:47.908 22935 22935 W binder:22935_E: type=1400 audit(0.0:1041555): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:47.908 22935 22935 W binder:22935_E: type=1400 audit(0.0:1041556): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:47.912 22935 22935 W binder:22935_7: type=1400 audit(0.0:1041557): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:48.198 25878 25989 D nativeloader: Load /data/app/~~ufvjVI22T6YFfSonN-ae0g==/com.google.android.apps.photos-EdhdDit8bdnV8Xpp4OZgmw==/lib/arm64/libnative_crash_handler_jni.so using class loader ns clns-9 (caller=/data/app/~~ufvjVI22T6YFfSonN-ae0g==/com.google.android.apps.photos-EdhdDit8bdnV8Xpp4OZgmw==/base.apk!classes2.dex): ok
07-04 17:18:48.531 23530 24572 D SuspensionManager: le, com.stepstone.borowf01, com.google.android.settings.future.biometrics.faceenroll, com.github.capntrips.kernelflasher, com.Saplin.CPDT, com.google.android.apps.diagnosticstool, com.google.euiccpixel.permissions, com.google.euiccpixel, com.indeed.android.jobsearch, com.google.android.flipendo, com.revolut.revolut, com.android.settings.overlay.gp4bc, com.google.android.storagemanager.auto_generated_rro_product__, com.google.android.apps.pixel.relationships, com.google.android.overlay.glanceable
07-04 17:18:48.531 23530 24572 D SuspensionManager: tsapp, com.google.android.telecomui, com.kimchangyoun.rootbeerFresh.sample, com.substack.app, com.google.android.telephony, de.number26.android, com.android.companiondevicemanager, cz.alza.eshop, com.android.mms.service, fr.vinted, com.henrikherzig.playintegritychecker, at.aztec.customer, com.tradingview.tradingviewapp, com.mcdonalds.mobileapp, com.coderstory.toolkit, com.android.providers.downloads, ru.zdevs.zugate, at.mydpd, com.google.android.apps.authenticator2, com.google.android.health.con
07-04 17:18:48.532 23530 24572 D SuspensionManager: allet, com.google.ar.core, com.google.ar.lens, com.google.android.apps.emojiwallpaper, com.android.providers.downloads.ui, com.google.android.hotspot2.osulogin, com.android.vending, com.android.pacprocessor, ag.jup.jupiter.android, com.android.simappdialog, com.zyncas.signals, com.android.cellbroadcastreceiver.overlay.pixel, eu.darken.sdmse, com.fankes.apperrorstracking, com.google.android.adservices.api, com.dergoogler.mmrl, com.android.systemui.clocks.growth, com.urbandroid.sleep.addon.port, a
07-04 17:18:48.532 23530 24572 D SuspensionManager: tivity, com.android.egg, com.android.mtp, com.android.nfc, com.android.ons, com.android.qns, com.android.stk, com.google.android.pixel.avatarpicker, org.parcello, com.android.backupconfirm, com.isaiasmatewos.texpand, at.apptec.br, com.amazon.dee.app, com.instagram.android, jasi2169.tbcrashfixer, com.deepseek.chat, com.android.settings.auto_generated_rro_vendor__, io.github.auag0.disableaudiofocus, com.amazon.drive, at.itsv.mobile.meinesvstatus, com.android.systemui.auto_generated_rro_vendor__, c
07-04 17:18:48.846 22935 24608 W PackageManager: No change is needed for package: com.revolut.revolut. Skipping suspending/un-suspending.
07-04 17:18:48.856 22935 24608 W PackageManager: No change is needed for package: com.henrikherzig.playintegritychecker. Skipping suspending/un-suspending.
07-04 17:18:48.888 22935 22935 W binder:22935_15: type=1400 audit(0.0:1042717): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:48.888 22935 22935 W binder:22935_15: type=1400 audit(0.0:1042718): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:48.888 22935 22935 W binder:22935_15: type=1400 audit(0.0:1042719): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:48.888 22935 22935 W binder:22935_15: type=1400 audit(0.0:1042720): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:48.892 22935 22935 W binder:22935_15: type=1400 audit(0.0:1042721): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:48.938 22935 24608 W PackageManager: No change is needed for package: com.fankes.apperrorstracking. Skipping suspending/un-suspending.
07-04 17:18:48.974 22935 24608 W PackageManager: No change is needed for package: jasi2169.tbcrashfixer. Skipping suspending/un-suspending.
07-04 17:18:49.065 25978 25978 I LSPosedFramework: (com.google.android.googlequicksearchbox:search)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,657a-19f2db5fbe7-2-1,0,1] v1.2.0 loaded in com.google.android.googlequicksearchbox:search
07-04 17:18:49.136 22935 22996 I system_server: IncrementDisableThreadFlip blocked for 37.643ms
07-04 17:18:49.480 25978 25978 W LSPosedFramework: (com.google.android.googlequicksearchbox:search)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,657a-19f2db5fbe7-2-2,0,1] skipped proc=com.google.android.googlequicksearchbox:search v=301766375 reason=no cache for AGSA v301766375, run Verify from module app lastRemoteWrite=0
07-04 17:18:49.491 25978 25978 W LSPosedFramework: (com.google.android.googlequicksearchbox:search)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,657a-19f2db5fbe7-2-3,0,1] no stream method in cache proc=com.google.android.googlequicksearchbox:search reason=no cache for AGSA v301766375, run Verify from module app, open Discover Ads Filter and tap Verify
07-04 17:18:49.493 25978 25978 I LSPosedFramework: (com.google.android.googlequicksearchbox:search)[eu.hxreborn.discoveradsfilter,DiscoverAdsFilter,657a-19f2db5fbe7-2-4,0,1] installed proc=com.google.android.googlequicksearchbox:search agsaV=301766375 hooks=0/1 failed:StreamSliceFilterHook Missing(no cache for AGSA v301766375, run Verify from module app)
07-04 17:18:49.795 25978 26089 D nativeloader: Load /data/app/~~RPqWUUxyXqbFwJOifbdNKA==/com.google.android.googlequicksearchbox-Dn255FfrdcDAI39Zem6a7Q==/base.apk!/lib/arm64-v8a/libnative_crash_handler_jni.so using class loader ns clns-9 (caller=/data/app/~~RPqWUUxyXqbFwJOifbdNKA==/com.google.android.googlequicksearchbox-Dn255FfrdcDAI39Zem6a7Q==/base.apk!classes3.dex): ok
07-04 17:18:49.892 22935 22935 W binder:22935_10: type=1400 audit(0.0:1044124): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:49.892 22935 22935 W binder:22935_10: type=1400 audit(0.0:1044125): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:49.892 22935 22935 W binder:22935_10: type=1400 audit(0.0:1044126): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:49.892 22935 22935 W binder:22935_10: type=1400 audit(0.0:1044127): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:49.892 22935 22935 W binder:22935_10: type=1400 audit(0.0:1044128): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:50.519 22935 22992 I system_server: Background young concurrent mark compact GC freed 219MB AllocSpace bytes, 1712(33MB) LOS objects, 19% free, 411MB/512MB, paused 26.831ms,46.856ms total 2.096s
07-04 17:18:50.896 22935 22935 W binder:22935_F: type=1400 audit(0.0:1048563): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:50.896 22935 22935 W binder:22935_F: type=1400 audit(0.0:1048564): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:50.896 22935 22935 W binder:22935_F: type=1400 audit(0.0:1048565): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:50.896 22935 22935 W binder:22935_F: type=1400 audit(0.0:1048566): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:50.896 22935 22935 W binder:22935_F: type=1400 audit(0.0:1048567): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:51.225 22935 22935 W Looper  : Slow dispatch took 49415ms main app=system_server main=true group=FOREGROUND h=android.app.ActivityThread$H c=null m=114
07-04 17:18:51.267 22935 23072 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.268 22935 23736 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.274 22935 23068 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.274 22935 23357 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.280 22935 23900 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.283 22935 23958 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.285 22935 23878 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.290 22935 25318 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.322 22935 23948 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.324 22935 23727 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.390 22935 23301 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.524 22935 25312 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:51.878 22935 22992 I system_server: Background concurrent mark compact GC freed 326MB AllocSpace bytes, 2219(47MB) LOS objects, 72% free, 138MB/512MB, paused 2.158ms,4.009ms total 1.348s
07-04 17:18:51.879 22935 23072 I system_server: WaitForGcToComplete blocked Alloc on Background for 611.759ms
07-04 17:18:51.879 22935 23736 I system_server: WaitForGcToComplete blocked Alloc on Background for 610.486ms
07-04 17:18:51.880 22935 23068 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 605.647ms
07-04 17:18:51.882 22935 23357 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 607.288ms
07-04 17:18:51.883 22935 23900 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 602.936ms
07-04 17:18:51.884 22935 23958 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 601.598ms
07-04 17:18:51.885 22935 23948 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 562.913ms
07-04 17:18:51.885 22935 23878 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 599.902ms
07-04 17:18:51.886 22935 25318 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 595.655ms
07-04 17:18:51.886 22935 25312 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 362.151ms
07-04 17:18:51.887 22935 23727 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 562.800ms
07-04 17:18:51.887 22935 23301 I system_server: WaitForGcToComplete blocked Alloc on HeapTrim for 497.094ms
07-04 17:18:51.900 22935 22935 W binder:22935_3: type=1400 audit(0.0:1049550): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:51.900 22935 22935 W binder:22935_3: type=1400 audit(0.0:1049551): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:51.900 22935 22935 W binder:22935_3: type=1400 audit(0.0:1049552): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:51.900 22935 22935 W binder:22935_3: type=1400 audit(0.0:1049553): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:51.900 22935 22935 W binder:22935_3: type=1400 audit(0.0:1049554): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:52.135 22935 22935 W Looper  : Slow dispatch took 891ms main app=system_server main=true group=FOREGROUND h=android.app.ActivityThread$H c=null m=121
07-04 17:18:52.260 22935 22935 E LSPosedFramework: (system)[unknown,XposedBridge,5997-19f2db50641-2-25,0,1] java.lang.NullPointerException: Attempt to invoke virtual method 'boolean java.lang.String.equals(java.lang.Object)' on a null object reference
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at com.xposed.XSupport.handleLoadPackage(SourceFile:77)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at K.rIcJ.Z.GEA.s.NpFHAPy.IXposedHookLoadPackage$Wrapper.handleLoadPackage(r8-map-id-823ae3091f0e10f492e1835583e072f8ac77509a98c2d791618ad263abb31961:3)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at K.rIcJ.Z.GEA.s.NpFHAPy.callbacks.XC_LoadPackage.call(r8-map-id-823ae3091f0e10f492e1835583e072f8ac77509a98c2d791618ad263abb31961:7)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at K.rIcJ.Z.GEA.s.NpFHAPy.callbacks.XCallback.callAll(r8-map-id-823ae3091f0e10f492e1835583e072f8ac77509a98c2d791618ad263abb31961:33)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at t.intercept(r8-map-id-823ae3091f0e10f492e1835583e072f8ac77509a98c2d791618ad263abb31961:147)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at k.proceed(r8-map-id-823ae3091f0e10f492e1835583e072f8ac77509a98c2d791618ad263abb31961:33)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at o0.callback(r8-map-id-823ae3091f0e10f492e1835583e072f8ac77509a98c2d791618ad263abb31961:22)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.telephony.Trusielt.createOrUpdateClassLoaderLocked(Trusielt.java)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.app.LoadedApk.getClassLoader(LoadedApk.java:1283)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.app.LoadedApk.makeApplicationInner(LoadedApk.java:1634)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.app.LoadedApk.makeApplicationInner(LoadedApk.java:1590)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.app.ActivityThread.handleCreateService(ActivityThread.java:5607)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.app.ActivityThread.-$$Nest$mhandleCreateService(ActivityThread.java:0)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2804)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.os.Handler.dispatchMessageImpl(Handler.java:142)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.os.Handler.dispatchMessage(Handler.java:125)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.os.Looper.loopOnce(Looper.java:296)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at android.os.Looper.loop(Looper.java:397)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at com.android.server.SystemServer.run(SystemServer.java:1097)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at com.android.server.SystemServer.main(SystemServer.java:727)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at java.lang.reflect.Method.invoke(Native Method)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:575)
07-04 17:18:52.260 22935 22935 E LSPosedFramework: 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:917)
07-04 17:18:52.488 23772 23829 D AlphabeticIndexCompat: computeSectionName: cs: AppErrorsTracking sectionName: A
07-04 17:18:52.514 23772 23829 D AlphabeticIndexCompat: computeSectionName: cs: zygisk-detach sectionName: Z
07-04 17:18:52.538 23772 23829 D AlphabeticIndexCompat: computeSectionName: cs: Revolut sectionName: R
07-04 17:18:52.594 23772 23829 D AlphabeticIndexCompat: computeSectionName: cs: TB Crash Fixer sectionName: T
07-04 17:18:52.904 22935 22935 W binder:22935_F: type=1400 audit(0.0:1052682): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:52.904 22935 22935 W binder:22935_F: type=1400 audit(0.0:1052683): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:52.908 22935 22935 W binder:22935_3: type=1400 audit(0.0:1052684): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:52.908 22935 22935 W binder:22935_3: type=1400 audit(0.0:1052685): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:52.916 22935 22935 W binder:22935_C: type=1400 audit(0.0:1052686): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:52.970 23594 23594 D BluetoothKeystoreService: new BluetoothKeystoreService
07-04 17:18:53.637 26262 26288 D nativeloader: Load /data/app/~~g6rTqqrtEvzt5mN9qt0o_Q==/com.google.android.apps.messaging-8jNgVrdAEQmm1YoME1WWcA==/split_config.arm64_v8a.apk!/lib/arm64-v8a/libnative_crash_handler_jni.so using class loader ns clns-10 (caller=/data/app/~~g6rTqqrtEvzt5mN9qt0o_Q==/com.google.android.apps.messaging-8jNgVrdAEQmm1YoME1WWcA==/base.apk!classes3.dex): ok
07-04 17:18:53.841  4797  7248 I TEESimulator: [TX_ID: 900] No cached chain for KeyIdentifier(uid=10129, alias=auth_account:lst:darklaunch:ff7e7044-8e24-4aea-aa1b-8d5e6a95384e). Performing live patch as a fallback.
07-04 17:18:53.842  4797  7248 I TEESimulator: Using EC keybox keybox.xml; attestation cert serials (hex): 325cb9fb9a68828bd3e827f02e829243, d03e8f81bd604bce7579a6c56950e644, d50ff25ba3f2d6b3
07-04 17:18:53.845  4797  7248 I TEESimulator: Attestation patch levels for uid=10129: os=-1, vendor=20260605, boot=20260605
07-04 17:18:53.850  4797  7248 I TEESimulator: Successfully rebuilt a valid, patched certificate chain for UID 10129.
07-04 17:18:53.908 22935 22935 W binder:22935_16: type=1400 audit(0.0:1054679): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:53.908 22935 22935 W binder:22935_16: type=1400 audit(0.0:1054680): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:53.908 22935 22935 W binder:22935_16: type=1400 audit(0.0:1054681): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:53.908 22935 22935 W binder:22935_16: type=1400 audit(0.0:1054682): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:53.908 22935 22935 W binder:22935_16: type=1400 audit(0.0:1054683): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:54.102  4797  7248 I TEESimulator: [TX_ID: 903] StrongBox op limit reached for uid=10129 (hw=0 sw=4 max=4)
07-04 17:18:54.106 23918 24728 W Auth    : [HardwareKeyHelper] AndroidKeyStore entry is unrecoverable [CONTEXT service_id=343 ]
07-04 17:18:54.722 22935 23070 W Looper  : Slow dispatch took 20807ms android.bg app=system_server main=false group=SYSTEM h=android.os.Handler c=com.android.server.print.PrintManagerService$PrintManagerImpl$3@dab9a43 m=0
07-04 17:18:54.916 22935 22935 W binder:22935_6: type=1400 audit(0.0:1056378): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:54.916 22935 22935 W binder:22935_15: type=1400 audit(0.0:1056379): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:54.916 22935 22935 W binder:22935_15: type=1400 audit(0.0:1056380): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:54.920 22935 22935 W binder:22935_6: type=1400 audit(0.0:1056381): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:54.920 22935 22935 W binder:22935_15: type=1400 audit(0.0:1056382): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:55.195 22935 22992 I system_server: Background young concurrent mark compact GC freed 145MB AllocSpace bytes, 23(1156KB) LOS objects, 59% free, 205MB/512MB, paused 27.096ms,14.870ms total 1.223s
07-04 17:18:55.920 22935 22935 W binder:22935_6: type=1400 audit(0.0:1059722): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:55.920 22935 22935 W binder:22935_6: type=1400 audit(0.0:1059723): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:55.920 22935 22935 W binder:22935_6: type=1400 audit(0.0:1059724): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:55.920 22935 22935 W binder:22935_6: type=1400 audit(0.0:1059725): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:55.924 22935 22935 W binder:22935_6: type=1400 audit(0.0:1059726): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:56.141 23772 23829 D AlphabeticIndexCompat: computeSectionName: cs: Revolut sectionName: R
07-04 17:18:56.726 22935 23070 E system_server: No package ID 7f found for resource ID 0x7f1901d5.
07-04 17:18:56.920 22935 22935 W binder:22935_14: type=1400 audit(0.0:1063370): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:56.924 22935 22935 W binder:22935_14: type=1400 audit(0.0:1063371): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:56.924 22935 22935 W binder:22935_14: type=1400 audit(0.0:1063372): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:56.924 22935 22935 W binder:22935_14: type=1400 audit(0.0:1063373): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:56.924 22935 22935 W binder:22935_14: type=1400 audit(0.0:1063374): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:57.211 22935 23070 E system_server: No package ID 7f found for resource ID 0x7f1901d5.
07-04 17:18:57.639  4797  7248 E TEESimulator: Error during generateKey handling for UID 10129.
07-04 17:18:57.639  4797  7248 E TEESimulator: DeadSystemException: The system died; earlier logs will point to the root cause
07-04 17:18:57.657 22935 23415 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.659 22935 23877 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.659 22935 24608 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.660 22935 22935 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.669   552 26454 I keystore2: system/security/keystore2/src/utils.rs:876 - setting niceness 0 from current 9
07-04 17:18:57.669 22935 26455 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.725 22935 23265 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.725 22935 23392 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.725 22935 23958 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.725 22935 23702 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.726 22935 25276 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.726 22935 23068 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.737 22935 23301 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.737 22935 25312 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.781 22935 23095 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.782 22935 23459 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.783 22935 23397 I system_server: Waiting for a blocking GC Alloc
07-04 17:18:57.968 22935 22992 I system_server: Background concurrent mark compact GC freed 267MB AllocSpace bytes, 4485(87MB) LOS objects, 69% free, 157MB/512MB, paused 42.861ms,3.806ms total 1.767s
07-04 17:18:57.968 22935 23415 I system_server: WaitForGcToComplete blocked Alloc on Background for 311.210ms
07-04 17:18:57.969 22935 23877 I system_server: WaitForGcToComplete blocked Alloc on Background for 310.683ms
07-04 17:18:57.964 22935 22935 W binder:22935_E: type=1400 audit(0.0:1065411): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:57.970 22935 24608 I system_server: WaitForGcToComplete blocked Alloc on Background for 310.759ms
07-04 17:18:57.977 22935 22935 I system_server: WaitForGcToComplete blocked Alloc on Background for 316.312ms
07-04 17:18:57.977 22935 26455 I system_server: WaitForGcToComplete blocked Alloc on Background for 307.836ms
07-04 17:18:57.977 22935 23265 I system_server: WaitForGcToComplete blocked Alloc on Background for 252.505ms
07-04 17:18:57.978 22935 23392 I system_server: WaitForGcToComplete blocked Alloc on Background for 252.543ms
07-04 17:18:57.978 22935 23958 I system_server: WaitForGcToComplete blocked Alloc on Background for 252.406ms
07-04 17:18:57.978 22935 23702 I system_server: WaitForGcToComplete blocked Alloc on Background for 252.832ms
07-04 17:18:57.978 22935 25276 I system_server: WaitForGcToComplete blocked Alloc on Background for 252.610ms
07-04 17:18:57.979 22935 23068 I system_server: WaitForGcToComplete blocked Alloc on Background for 253.193ms
07-04 17:18:57.982 22935 23301 I system_server: WaitForGcToComplete blocked Alloc on Background for 245.074ms
07-04 17:18:57.983 22935 25312 I system_server: WaitForGcToComplete blocked Alloc on Background for 245.831ms
07-04 17:18:57.983 22935 23095 I system_server: WaitForGcToComplete blocked Alloc on Background for 202.482ms
07-04 17:18:57.983 22935 23459 I system_server: WaitForGcToComplete blocked Alloc on Background for 200.911ms
07-04 17:18:57.984 22935 23397 I system_server: WaitForGcToComplete blocked Alloc on Background for 201.382ms
07-04 17:18:57.993 22935 23415 W Looper  : Slow dispatch took 326ms android.perm app=system_server main=false group=FOREGROUND h=android.os.Handler c=com.android.internal.infra.ServiceConnector$Impl$$ExternalSyntheticLambda2@86cc216 m=0
07-04 17:18:57.980 22935 22935 W binder:22935_1: type=1400 audit(0.0:1065412): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:57.980 22935 22935 W binder:22935_19: type=1400 audit(0.0:1065413): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:57.980 22935 22935 W binder:22935_1: type=1400 audit(0.0:1065414): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:57.980 22935 22935 W binder:22935_19: type=1400 audit(0.0:1065415): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:58.161  4797  7248 E TEESimulator: Error during generateKey handling for UID 10129.
07-04 17:18:58.161  4797  7248 E TEESimulator: DeadSystemException: The system died; earlier logs will point to the root cause
07-04 17:18:58.176 24601 24713 W KeyAttestationHandler: Device supports DeviceIdAttestation, but KeyStoreException is caught with error code 10 [CONTEXT service_id=130 ]
07-04 17:18:58.263  4797  7248 I TEESimulator: [TX_ID: 908] Returning KEY_NOT_FOUND for deleted key checkin_attestation
07-04 17:18:58.968 22935 22935 W binder:22935_15: type=1400 audit(0.0:1068555): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:58.968 22935 22935 W binder:22935_15: type=1400 audit(0.0:1068556): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:58.968 22935 22935 W binder:22935_15: type=1400 audit(0.0:1068557): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:58.968 22935 22935 W binder:22935_15: type=1400 audit(0.0:1068558): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30362 scontext=u:r:system_server:s0 tcontext=u:object_r:media_userdir_file:s0 tclass=file permissive=0
07-04 17:18:58.968 22935 22935 W binder:22935_15: type=1400 audit(0.0:1068559): avc:  denied  { read } for  name="l53202" dev="dm-59" ino=30366 scontext=u:r:system_server:s0 tcontext=u:object_r:system_data_root_file:s0 tclass=file permissive=0
07-04 17:18:59.536 22935 22992 W system_server: Suspending all threads took: 13.598ms
