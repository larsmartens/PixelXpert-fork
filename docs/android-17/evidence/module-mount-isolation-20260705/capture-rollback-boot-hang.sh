#!/system/bin/sh
set -eu
OUT=/data/local/tmp/rollback-boot-hang-summary.txt
: > "$OUT"

date >> "$OUT"
getprop sys.boot_completed >> "$OUT"

echo "== modules ==" >> "$OUT"
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  id="${d##*/}"
  state=enabled
  [ -e "$d/disable" ] && state=disabled
  skip=0
  [ -e "$d/skip_mount" ] && skip=1
  ver=$(sed -n 's/^version=//p' "$d/module.prop" 2>/dev/null | head -1)
  echo "$id state=$state skip=$skip version=$ver"
done | sort >> "$OUT"

echo "== dropbox ==" >> "$OUT"
ls -lt /data/system/dropbox/system_server_crash* /data/system/dropbox/system_server_watchdog* /data/system/dropbox/system_server_pre_watchdog* /data/system/dropbox/system_server_anr* 2>/dev/null |
  head -40 >> "$OUT" || true
f=$(ls -t /data/system/dropbox/system_server_crash* 2>/dev/null | head -1 || true)
echo "newest=$f" >> "$OUT"
if [ -n "$f" ]; then
  sed -n '1,140p' "$f" >> "$OUT" 2>/dev/null || true
fi

echo "== tombstones ==" >> "$OUT"
ls -lt /data/tombstones 2>/dev/null | head -40 >> "$OUT" || true

echo "$OUT"
