#!/system/bin/sh
set -eu

WORK=/data/adb/pixelxpert-stage/teesim-minimal-targets-20260705-1615
CONF=/data/adb/tricky_store/target.txt
mkdir -p "$WORK"

[ -f "$CONF" ] || { echo "missing $CONF"; exit 1; }
cp -p "$CONF" "$WORK/target.txt.before"
sha256sum "$WORK/target.txt.before"

cat > "$WORK/rollback-restore-teesim-targets.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
WORK=/data/adb/pixelxpert-stage/teesim-minimal-targets-20260705-1615
CONF=/data/adb/tricky_store/target.txt
cp -p "$WORK/target.txt.before" "$CONF"
chown root:root "$CONF"
chmod 0600 "$CONF"
chcon u:object_r:adb_data_file:s0 "$CONF" 2>/dev/null || true
sha256sum "$CONF"
echo "restored $CONF"
ROLLBACK
chmod 0700 "$WORK/rollback-restore-teesim-targets.sh"

cat > "$CONF" <<'TARGETS'
# Minimal Play Integrity attestation targets.
# Checker apps are intentionally excluded; Play Store/GMS own the token path.
com.google.android.gms
com.google.android.gsf
com.android.vending
TARGETS
chown root:root "$CONF"
chmod 0600 "$CONF"
chcon u:object_r:adb_data_file:s0 "$CONF" 2>/dev/null || true

sha256sum "$CONF"
ls -lZ "$CONF" "$WORK/target.txt.before" "$WORK/rollback-restore-teesim-targets.sh"
echo "rollback=$WORK/rollback-restore-teesim-targets.sh"
