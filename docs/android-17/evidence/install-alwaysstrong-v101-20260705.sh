#!/system/bin/sh
set -eu

ZIP=/data/local/tmp/AlwaysStrong-v1.0.1.zip
STAGE=/data/adb/pixelxpert-stage/alwaysstrong-v101-20260705
MODULES=/data/adb/modules
KSUD=/data/adb/ksu/bin/ksud
BB=/data/adb/ksu/bin/busybox
if [ ! -x "$BB" ]; then
  BB=busybox
fi

"$BB" mkdir -p "$STAGE"
"$KSUD" module list > "$STAGE/module-list.before.json" 2>/dev/null || true

[ -e "$MODULES/playintegrityfix" ] && "$BB" tar -cf "$STAGE/module-playintegrityfix.before.tar" -C "$MODULES" playintegrityfix
[ -e "$MODULES/tricky_store" ] && "$BB" tar -cf "$STAGE/module-tricky_store.before.tar" -C "$MODULES" tricky_store
[ -e /data/adb/tricky_store ] && "$BB" tar -cf "$STAGE/config-tricky_store.before.tar" -C /data/adb tricky_store

"$BB" sha256sum "$ZIP" > "$STAGE/AlwaysStrong-v1.0.1.zip.sha256"
"$BB" sha256sum /data/adb/tricky_store/keybox.xml > "$STAGE/keybox.before.sha256" 2>/dev/null || true

"$KSUD" module install "$ZIP"

# Prevent background keybox replacement during evaluation; keep the existing keybox.
"$BB" mkdir -p /data/adb/tricky_store
: > /data/adb/tricky_store/no_auto_keybox

"$KSUD" module list > "$STAGE/module-list.after-install.json" 2>/dev/null || true
"$BB" sha256sum /data/adb/tricky_store/keybox.xml > "$STAGE/keybox.after-install.sha256" 2>/dev/null || true

cat > "$STAGE/rollback-restore-pif-tee.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
STAGE=/data/adb/pixelxpert-stage/alwaysstrong-v101-20260705
MODULES=/data/adb/modules
rm -rf "$MODULES/tricky_store" "$MODULES/playintegrityfix" /data/adb/tricky_store
[ -f "$STAGE/module-playintegrityfix.before.tar" ] && tar -C "$MODULES" -xpf "$STAGE/module-playintegrityfix.before.tar"
[ -f "$STAGE/module-tricky_store.before.tar" ] && tar -C "$MODULES" -xpf "$STAGE/module-tricky_store.before.tar"
[ -f "$STAGE/config-tricky_store.before.tar" ] && tar -C /data/adb -xpf "$STAGE/config-tricky_store.before.tar"
rm -f "$MODULES/tricky_store/remove" "$MODULES/tricky_store/disable" "$MODULES/playintegrityfix/remove" "$MODULES/playintegrityfix/disable" 2>/dev/null || true
ROLLBACK
chmod 0755 "$STAGE/rollback-restore-pif-tee.sh"

echo "installed=AlwaysStrong-v1.0.1"
echo "stage=$STAGE"
echo "rollback=$STAGE/rollback-restore-pif-tee.sh"
