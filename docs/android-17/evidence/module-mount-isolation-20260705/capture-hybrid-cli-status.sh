#!/system/bin/sh
set -eu
OUT=/data/local/tmp/hybrid-cli-status.txt
: > "$OUT"
BIN=/data/adb/modules/hybrid_mount/hybrid-mount

echo "== identity ==" >> "$OUT"
date >> "$OUT"
id >> "$OUT"
getprop sys.boot_completed >> "$OUT"

echo "== binary ==" >> "$OUT"
ls -lZ "$BIN" >> "$OUT" 2>&1 || true

echo "== help ==" >> "$OUT"
"$BIN" --help >> "$OUT" 2>&1 || true

echo "== daemon status ==" >> "$OUT"
"$BIN" daemon status >> "$OUT" 2>&1 || true

echo "== logs ==" >> "$OUT"
"$BIN" logs >> "$OUT" 2>&1 || true

echo "== config test/list commands ==" >> "$OUT"
"$BIN" config >> "$OUT" 2>&1 || true
"$BIN" module >> "$OUT" 2>&1 || true
"$BIN" mount >> "$OUT" 2>&1 || true

echo "== run files ==" >> "$OUT"
find /data/adb/hybrid-mount/run -maxdepth 2 -type f -print 2>/dev/null >> "$OUT" || true
for f in /data/adb/hybrid-mount/run/*; do
  [ -f "$f" ] || continue
  echo "-- $f --" >> "$OUT"
  sed -n '1,160p' "$f" >> "$OUT" 2>&1 || true
done

echo "$OUT"
