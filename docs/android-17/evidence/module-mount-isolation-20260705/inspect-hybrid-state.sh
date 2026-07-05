#!/system/bin/sh
set -eu
OUT=/data/local/tmp/hybrid-state-before-isolation.txt
: > "$OUT"

echo "== identity ==" >> "$OUT"
date >> "$OUT"
id >> "$OUT"
getprop sys.boot_completed >> "$OUT"

echo "== hybrid module dirs ==" >> "$OUT"
ls -la /data/adb/modules/hybrid_mount /data/adb/modules_update/hybrid_mount >> "$OUT" 2>&1 || true

echo "== hybrid config ==" >> "$OUT"
sed -n '1,220p' /data/adb/hybrid-mount/config.toml >> "$OUT" 2>&1 || true

echo "== marker state ==" >> "$OUT"
for m in hybrid_mount ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos PixelXpert; do
  echo "-- $m --" >> "$OUT"
  ls -la /data/adb/modules/$m/disable /data/adb/modules/$m/skip_mount /data/adb/modules/$m/a17_enable_privapp_mount >> "$OUT" 2>&1 || true
done

echo "$OUT"
