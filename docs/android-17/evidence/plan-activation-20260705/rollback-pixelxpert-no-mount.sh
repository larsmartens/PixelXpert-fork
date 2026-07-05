#!/system/bin/sh
set -eu

if [ -x /data/adb/pixelxpert-stage/pixelxpert-no-mount-20260705/rollback.sh ]; then
  /system/bin/sh /data/adb/pixelxpert-stage/pixelxpert-no-mount-20260705/rollback.sh
else
  MOD=/data/adb/modules/PixelXpert
  touch "$MOD/disable"
  touch "$MOD/skip_mount"
  rm -f "$MOD/a17_enable_privapp_mount" "$MOD/mount_error"
  echo "fallback rollback applied"
fi
