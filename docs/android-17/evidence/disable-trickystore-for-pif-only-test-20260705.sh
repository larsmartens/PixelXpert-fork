#!/system/bin/sh
set -eu

STAGE=/data/adb/pixelxpert-stage/pif-only-no-trickystore-20260705
KSUD=/data/adb/ksu/bin/ksud
BB=/data/adb/ksu/bin/busybox
if [ ! -x "$BB" ]; then
  BB=busybox
fi

"$BB" mkdir -p "$STAGE"
"$KSUD" module list > "$STAGE/module-list.before.json" 2>/dev/null || true
"$BB" sha256sum /data/adb/modules/tricky_store/module.prop > "$STAGE/tricky_store.module.prop.sha256" 2>/dev/null || true

"$KSUD" module disable tricky_store
"$KSUD" module list > "$STAGE/module-list.after.json" 2>/dev/null || true

cat > "$STAGE/rollback-enable-trickystore.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
/data/adb/ksu/bin/ksud module enable tricky_store
ROLLBACK
chmod 0755 "$STAGE/rollback-enable-trickystore.sh"

echo "disabled=tricky_store"
echo "stage=$STAGE"
echo "rollback=$STAGE/rollback-enable-trickystore.sh"
