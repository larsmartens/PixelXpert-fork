#!/system/bin/sh
set -eu

TS_DIR=/data/adb/tricky_store
STAGE=/data/adb/pixelxpert-stage/trickystore-generate-mode-targets-20260705
TARGET="$TS_DIR/target.txt"
BB=/data/adb/ksu/bin/busybox
if [ ! -x "$BB" ]; then
  BB=busybox
fi

"$BB" mkdir -p "$STAGE"
"$BB" cp -af "$TARGET" "$STAGE/target.txt.before"
"$BB" sha256sum "$TARGET" > "$STAGE/target.txt.before.sha256" 2>/dev/null || true

cat > "$STAGE/target.txt.new" <<'TARGETS'
# Play Integrity and attestation test targets.
# Force certificate generation mode for Android 17/KeyMint testing.
com.google.android.gms!
com.google.android.gsf!
com.android.vending!
com.henrikherzig.playintegritychecker!
gr.nikolasspyr.integritycheck!
io.github.vvb2060.keyattestation!
TARGETS

"$BB" cp -af "$STAGE/target.txt.new" "$TARGET"
"$BB" chmod 0644 "$TARGET"
"$BB" sha256sum "$TARGET" > "$STAGE/target.txt.after.sha256" 2>/dev/null || true

cat > "$STAGE/rollback-restore-targets.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
cp -af /data/adb/pixelxpert-stage/trickystore-generate-mode-targets-20260705/target.txt.before /data/adb/tricky_store/target.txt
chmod 0644 /data/adb/tricky_store/target.txt
ROLLBACK
chmod 0755 "$STAGE/rollback-restore-targets.sh"

echo "updated_target=$TARGET"
echo "stage=$STAGE"
echo "rollback=$STAGE/rollback-restore-targets.sh"
"$BB" cat "$STAGE/target.txt.before.sha256" 2>/dev/null || true
"$BB" cat "$STAGE/target.txt.after.sha256" 2>/dev/null || true
