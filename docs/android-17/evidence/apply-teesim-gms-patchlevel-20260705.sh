#!/system/bin/sh
set -eu

STAMP=teesim-gms-patchlevel-20260705-$(date +%H%M%S)
STAGE=/data/adb/pixelxpert-stage/$STAMP
CONFIG=/data/adb/tricky_store/security_patch.txt
NEW=/data/local/tmp/security_patch.$STAMP.txt
ROLLBACK=$STAGE/rollback-restore-teesim-security-patch.sh

mkdir -p "$STAGE"

if [ -f "$CONFIG" ]; then
  cp -a "$CONFIG" "$STAGE/security_patch.txt.before"
  sha256sum "$CONFIG" > "$STAGE/security_patch.txt.before.sha256"
fi

cat > "$NEW" <<'EOF'
all=2026-06-05
EOF

cat > "$ROLLBACK" <<EOF
#!/system/bin/sh
set -eu
if [ -f "$STAGE/security_patch.txt.before" ]; then
  cp -a "$STAGE/security_patch.txt.before" "$CONFIG"
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
echo "before_hash=$(cat "$STAGE/security_patch.txt.before.sha256" 2>/dev/null || true)"
echo "after_hash=$(sha256sum "$CONFIG")"
echo "after_content:"
sed -n '1,40p' "$CONFIG"
