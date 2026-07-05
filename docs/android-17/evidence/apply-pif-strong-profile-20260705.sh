#!/system/bin/sh
set -eu

MOD=/data/adb/modules/playintegrityfix
WORK=/data/adb/pixelxpert-stage/pif-strong-profile-20260705-1620
mkdir -p "$WORK"

for f in \
  "$MOD/custom.pif.prop" \
  "$MOD/autopif4/pif.prop" \
  "$MOD/autopif4/custom.pif.prop"; do
  [ -f "$f" ] || continue
  cp -p "$f" "$WORK/$(basename "$f").before"
  sha256sum "$WORK/$(basename "$f").before"
done

cat > "$WORK/rollback-restore-pif-profile.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
MOD=/data/adb/modules/playintegrityfix
WORK=/data/adb/pixelxpert-stage/pif-strong-profile-20260705-1620
for name in custom.pif.prop pif.prop; do
  if [ -f "$WORK/$name.before" ]; then
    case "$name" in
      custom.pif.prop) dest="$MOD/custom.pif.prop" ;;
      pif.prop) dest="$MOD/autopif4/pif.prop" ;;
    esac
    cp -p "$WORK/$name.before" "$dest"
    chown root:root "$dest"
    chmod 0600 "$dest"
    chcon u:object_r:system_file:s0 "$dest" 2>/dev/null || true
  fi
done
if [ -f "$WORK/custom.pif.prop.before" ]; then
  cp -p "$WORK/custom.pif.prop.before" "$MOD/autopif4/custom.pif.prop"
  chown root:root "$MOD/autopif4/custom.pif.prop"
  chmod 0600 "$MOD/autopif4/custom.pif.prop"
  chcon u:object_r:system_file:s0 "$MOD/autopif4/custom.pif.prop" 2>/dev/null || true
fi
sha256sum "$MOD/custom.pif.prop" "$MOD/autopif4/pif.prop" "$MOD/autopif4/custom.pif.prop" 2>/dev/null || true
echo "restored PIF profile"
ROLLBACK
chmod 0700 "$WORK/rollback-restore-pif-profile.sh"

/system/bin/sh "$MOD/autopif4.sh" -s -m

echo "## after"
for f in "$MOD/custom.pif.prop" "$MOD/autopif4/pif.prop" "$MOD/autopif4/custom.pif.prop"; do
  [ -f "$f" ] || continue
  ls -lZ "$f"
  sha256sum "$f"
  sed -n '1,120p' "$f"
done
echo "rollback=$WORK/rollback-restore-pif-profile.sh"
