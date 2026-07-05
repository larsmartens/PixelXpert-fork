#!/system/bin/sh
set -eu

echo "== boot =="
date
getprop sys.boot_completed
uname -a

echo "== modules =="
for m in rezygisk zygisksu playintegrityfix tricky_store zygisk_nohello zygisk_lsposed PixelXpert; do
  if [ -d "/data/adb/modules/${m}" ]; then
    echo "MODULE:${m}"
    if [ -f "/data/adb/modules/${m}/disable" ]; then echo "disable=yes"; else echo "disable=no"; fi
    if [ -f "/data/adb/modules/${m}/remove" ]; then echo "remove=yes"; else echo "remove=no"; fi
    grep -E '^(id|name|version|versionCode|description|managedFeatures)=' "/data/adb/modules/${m}/module.prop" 2>/dev/null || true
  fi
done

echo "== rezygisk files =="
ls -la /data/adb/modules/rezygisk /data/adb/modules/rezygisk/bin /data/adb/modules/rezygisk/lib64 2>/dev/null || true
ls -la /data/adb/post-fs-data.d/rezygisk.sh /data/adb/post-mount.d/rezygisk.sh 2>/dev/null || true
ls -Zd /data/adb/modules/rezygisk /data/adb/modules/rezygisk/bin /data/adb/modules/rezygisk/lib64 /data/adb/modules/rezygisk/lib64/libzygisk.so 2>/dev/null || true

echo "== processes =="
ps -A -o USER,PID,PPID,NAME,ARGS | grep -E 'rezygisk|zygisk|zygote|gms|integrity' | grep -v grep || true

echo "== logs =="
logcat -d -t 1200 | grep -Ei 'rezygisk|zygisk|PlayIntegrity|playintegrity|Tricky|TEE|attest|zygiskd' | tail -200 || true

echo "== dropbox =="
ls -lt /data/system/dropbox/system_server_crash* /data/system/dropbox/system_server_watchdog* /data/system/dropbox/system_server_pre_watchdog* /data/system/dropbox/system_server_anr* 2>/dev/null | head -20 || true

echo "== tombstones =="
ls -lt /data/tombstones 2>/dev/null | head -20 || true
