#!/system/bin/sh
set -eu
OUT=/data/local/tmp/hybrid-config-generator-probe.txt
: > "$OUT"
BIN=/data/adb/modules/hybrid_mount/hybrid-mount

echo "== identity ==" >> "$OUT"
date >> "$OUT"
id >> "$OUT"
getprop sys.boot_completed >> "$OUT"

echo "== version ==" >> "$OUT"
"$BIN" --version >> "$OUT" 2>&1 || true

echo "== gen-config help ==" >> "$OUT"
"$BIN" gen-config --help >> "$OUT" 2>&1 || true

echo "== gen-config stdout ==" >> "$OUT"
"$BIN" gen-config >> "$OUT" 2>&1 || true

echo "== daemon help ==" >> "$OUT"
"$BIN" daemon --help >> "$OUT" 2>&1 || true

echo "== logs help ==" >> "$OUT"
"$BIN" logs --help >> "$OUT" 2>&1 || true

echo "$OUT"
