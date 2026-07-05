# KSU-Next Manager And Kernel Update Evidence - 2026-07-05

## Facts

- Device: Pixel 7 Pro (`cheetah`), Android 17 build `CP2A.260605.012`, SDK 37.
- Active slot during the update: `b`.
- Manager was updated from KSU-Next v3.2.0 (`33129`) to v3.3.0 (`33214`) using the official normal release APK.
- Manager APK:
  - `KernelSU_Next_v3.3.0_33214-release.apk`
  - SHA-256: `fd0b12385c98fe9d5f4f1257b5f184e55c74c1376637507df0718305f5d7a924`
  - Source: <https://github.com/KernelSU-Next/KernelSU-Next/releases/tag/v3.3.0>
- Kernel was updated from blu_spark r265 to blu_spark r266 using the `gs-next` image, not the `gs-susfs` image.
- New boot image:
  - `blu_spark_r266-gs-next_d2697ac.img`
  - SHA-256: `718647c1cd2438b478da24aa9e0478c19a99297fb7d52af0e111b88dd90ab9ba`
  - Source: <https://github.com/engstk/gs/releases>
- Running kernel after flash:
  - `Linux localhost 6.1.157+blu-spark #266 SMP PREEMPT Tue Jun 30 19:09:41 WEST 2026 aarch64`
- Live `boot_b` hash after flash matched the downloaded r266 image hash.

## Rollback

- Active boot partition backup on device:
  - `/data/adb/pixelxpert-stage/bluspark-r266-backup-20260705-012844/boot_b.before.img`
- Local pulled backup:
  - `/tmp/bluspark-r266/boot_b.before.img`
- On-device rollback script:
  - `/data/adb/pixelxpert-stage/bluspark-r266-backup-20260705-012844/rollback-restore-boot_b.sh`

## Current Tradeoff

- r266 is the latest checked blu_spark KSU-Next option for this device/build.
- KSU-Next manager v3.3.0 is newer than the KSU-Next kernel side included in blu_spark r266, which still reports `KernelSU (33129)`.
- `ksud module list` works, but `ksud module install` currently fails with:
  - `UAPI version mismatch: kernel=0, ksud=2. Please update KernelSU!`
- Practical interpretation: the device is on the newest checked stable `gs-next` kernel image, but the latest manager/userspace is ahead of the kernel integration currently shipped by blu_spark.

## Open Question

- Wait for a newer blu_spark `gs-next` build with KSU-Next v3.3.x integration, or downgrade the manager/userspace back to v3.2.0 (`33129`) to restore fully compatible module install behavior.
