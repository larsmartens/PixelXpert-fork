#!/system/bin/sh
set -eu

STAMP=pif-spoof-vending-fingerprint-20260705-$(date +%H%M%S)
STAGE=/data/adb/pixelxpert-stage/$STAMP
CONFIG=/data/adb/modules/playintegrityfix/custom.pif.prop
TMP=/data/local/tmp/custom.pif.$STAMP.prop
ROLLBACK=$STAGE/rollback-restore-pif-custom-prop.sh

mkdir -p "$STAGE"
[ -f "$CONFIG" ] || { echo "missing $CONFIG"; exit 1; }

cp -a "$CONFIG" "$STAGE/custom.pif.prop.before"
sha256sum "$CONFIG" > "$STAGE/custom.pif.prop.before.sha256"

sed 's/^spoofVendingFinger=.*/spoofVendingFinger=1/' "$CONFIG" > "$TMP"
if ! grep -q '^spoofVendingFinger=' "$TMP"; then
  printf '\nspoofVendingFinger=1\n' >> "$TMP"
fi

cat > "$ROLLBACK" <<EOF
#!/system/bin/sh
set -eu
cp -a "$STAGE/custom.pif.prop.before" "$CONFIG"
chmod 0644 "$CONFIG"
chown root:root "$CONFIG" 2>/dev/null || true
restorecon "$CONFIG" 2>/dev/null || true
echo restored $CONFIG from $STAGE
EOF
chmod 0700 "$ROLLBACK"

cp "$TMP" "$CONFIG"
chmod 0644 "$CONFIG"
chown root:root "$CONFIG" 2>/dev/null || true
restorecon "$CONFIG" 2>/dev/null || true

echo "stage=$STAGE"
echo "rollback=$ROLLBACK"
echo "before_hash=$(cat "$STAGE/custom.pif.prop.before.sha256")"
echo "after_hash=$(sha256sum "$CONFIG")"
echo "changed_lines:"
grep -E '^(FINGERPRINT|spoofVendingFinger|spoofVendingSdk|spoofProvider|spoofBuild|spoofProps)=' "$CONFIG"
