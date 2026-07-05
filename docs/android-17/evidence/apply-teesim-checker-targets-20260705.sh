#!/system/bin/sh
set -eu

STAMP=teesim-checker-targets-20260705-$(date +%H%M%S)
STAGE=/data/adb/pixelxpert-stage/$STAMP
CONFIG=/data/adb/tricky_store/target.txt
NEW=/data/local/tmp/target.$STAMP.txt
ROLLBACK=$STAGE/rollback-restore-teesim-targets.sh

mkdir -p "$STAGE"

if [ -f "$CONFIG" ]; then
  cp -a "$CONFIG" "$STAGE/target.txt.before"
  sha256sum "$CONFIG" > "$STAGE/target.txt.before.sha256"
fi

cat > "$NEW" <<'EOF'
# Play Integrity and attestation test targets.
com.google.android.gms
com.google.android.gsf
com.android.vending
com.henrikherzig.playintegritychecker
gr.nikolasspyr.integritycheck
io.github.vvb2060.keyattestation
EOF

cat > "$ROLLBACK" <<EOF
#!/system/bin/sh
set -eu
if [ -f "$STAGE/target.txt.before" ]; then
  cp -a "$STAGE/target.txt.before" "$CONFIG"
  chmod 0644 "$CONFIG"
  chown root:root "$CONFIG" 2>/dev/null || true
  restorecon "$CONFIG" 2>/dev/null || true
else
  rm -f "$CONFIG"
fi
echo restored $CONFIG from $STAGE
EOF
chmod 0700 "$ROLLBACK"

cp "$NEW" "$CONFIG"
chmod 0644 "$CONFIG"
chown root:root "$CONFIG" 2>/dev/null || true
restorecon "$CONFIG" 2>/dev/null || true

echo "stage=$STAGE"
echo "rollback=$ROLLBACK"
echo "before_hash=$(cat "$STAGE/target.txt.before.sha256" 2>/dev/null || true)"
echo "after_hash=$(sha256sum "$CONFIG")"
echo "after_content:"
sed -n '1,80p' "$CONFIG"
