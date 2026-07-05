#!/system/bin/sh
set -eu
OUT=/data/local/tmp/hybrid-module-files.txt
: > "$OUT"
for f in \
  /data/adb/modules/hybrid_mount/service.sh \
  /data/adb/modules/hybrid_mount/metamount.sh \
  /data/adb/modules/hybrid_mount/module_blacklist.toml \
  /data/adb/modules/hybrid_mount/config.toml \
  /data/adb/modules/hybrid_mount/sepolicy.rule
do
  echo "== $f ==" >> "$OUT"
  sed -n '1,240p' "$f" >> "$OUT" 2>&1 || true
done
echo "$OUT"
