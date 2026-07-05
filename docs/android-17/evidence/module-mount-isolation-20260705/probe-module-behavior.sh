#!/system/bin/sh
set -eu

OUT=/data/local/tmp/module-behavior-probes.txt
: > "$OUT"

section() {
  echo >> "$OUT"
  echo "== $1 ==" >> "$OUT"
}

path_probe() {
  p="$1"
  echo "-- $p --" >> "$OUT"
  if [ -e "$p" ]; then
    ls -lZ "$p" >> "$OUT" 2>/dev/null || ls -l "$p" >> "$OUT" 2>/dev/null || true
    if [ -f "$p" ]; then
      sha256sum "$p" >> "$OUT" 2>/dev/null || true
    fi
  else
    echo "missing" >> "$OUT"
  fi
}

section "identity"
date >> "$OUT"
id >> "$OUT"
getprop sys.boot_completed >> "$OUT"
pidof system_server >> "$OUT" 2>/dev/null || true

section "pixelxpert no-mount invariant"
path_probe /system/priv-app/PixelXpert/PixelXpert.apk
path_probe /data/adb/modules/PixelXpert/system/priv-app/PixelXpert/PixelXpert.apk
pm path sh.siava.pixelxpert >> "$OUT" 2>/dev/null || true

section "viper targets"
path_probe /vendor/lib64/soundfx/libv4a_re.so
path_probe /vendor/lib/soundfx/libv4a_re.so
path_probe /vendor/etc/audio_effects.xml
path_probe /system/etc/audio_effects.xml
grep -R "v4a_re\\|ViPER" /vendor/etc /system/etc 2>/dev/null | head -80 >> "$OUT" || true
pm list packages | grep -Ei 'viper|v4a|re_equalizer' >> "$OUT" || true

section "rclone targets"
for p in /vendor/bin/rclone /vendor/bin/rclone-mount /vendor/bin/fusermount3 /system/vendor/bin/rclone; do
  path_probe "$p"
done
if command -v rclone >/dev/null 2>&1; then
  rclone version | head -20 >> "$OUT" 2>&1 || true
fi
pidof rclone >> "$OUT" 2>/dev/null || true
mount 2>/dev/null | grep -Ei 'rclone|fuse' | head -80 >> "$OUT" || true

section "tailscale targets"
for p in /system/bin/tailscale /system/bin/tailscaled /data/adb/modules/magisk-tailscaled/tailscale /data/adb/modules/magisk-tailscaled/tailscaled; do
  path_probe "$p"
done
pidof tailscaled >> "$OUT" 2>/dev/null || true
ip addr show tailscale0 >> "$OUT" 2>/dev/null || true
if command -v tailscale >/dev/null 2>&1; then
  tailscale status >> "$OUT" 2>&1 || true
fi

section "unlimited photos targets"
path_probe /system/etc/sysconfig/pixel_2016_exclusive.xml
path_probe /system/product/etc/sysconfig/pixel_2016_exclusive.xml
pm path com.google.android.apps.photos >> "$OUT" 2>/dev/null || true
dumpsys package com.google.android.apps.photos 2>/dev/null |
  grep -E 'versionCode=|versionName=|codePath=|enabled=' |
  head -60 >> "$OUT" || true

section "adguard app and service"
pm path com.adguard.android >> "$OUT" 2>/dev/null || true
dumpsys package com.adguard.android 2>/dev/null |
  grep -E 'versionCode=|versionName=|codePath=|enabled=' |
  head -60 >> "$OUT" || true
dumpsys vpn 2>/dev/null | grep -Ei 'adguard|vpn|user|owner|legacy|state' | head -120 >> "$OUT" || true

section "zygisk and lsposed process state"
pidof lspd >> "$OUT" 2>/dev/null || true
pidof magiskd >> "$OUT" 2>/dev/null || true
pidof zygote zygote64 >> "$OUT" 2>/dev/null || true
ps -A 2>/dev/null | grep -Ei 'lspd|zygisk|ksu|tailscale|rclone|adguard' | head -120 >> "$OUT" || true

section "recent crash markers"
ls -lt /data/system/dropbox/system_server_crash* /data/system/dropbox/system_server_watchdog* /data/system/dropbox/system_server_pre_watchdog* /data/system/dropbox/system_server_anr* 2>/dev/null |
  head -30 >> "$OUT" || true
ls -lt /data/tombstones 2>/dev/null | head -30 >> "$OUT" || true

echo "$OUT"
