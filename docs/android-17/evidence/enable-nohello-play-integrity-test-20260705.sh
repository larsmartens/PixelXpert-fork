#!/system/bin/sh
set -eu

MOD=/data/adb/modules/zygisk_nohello
BASE=/data/adb/pixelxpert-stage
TS=$(date +%Y%m%d-%H%M%S)
WORK="$BASE/play-integrity-nohello-$TS"
ROLLBACK="$WORK/rollback-disable-nohello.sh"

echo "## preflight"
date
id
[ -d "$MOD" ] || { echo "missing module: $MOD"; exit 1; }
mkdir -p "$WORK"
chmod 700 "$BASE" "$WORK" 2>/dev/null || true

echo
echo "## module before"
sed -n '1,80p' "$MOD/module.prop"
for f in "$MOD/disable" "$MOD/remove" "$MOD/update"; do
  [ -e "$f" ] && ls -lZ "$f"
done
if [ -f "$MOD/disable" ]; then
  cp -p "$MOD/disable" "$WORK/disable.before"
fi

cat > "$ROLLBACK" <<'EOF'
#!/system/bin/sh
set -eu
MOD=/data/adb/modules/zygisk_nohello
touch "$MOD/disable"
chown root:root "$MOD/disable"
chmod 644 "$MOD/disable"
chcon u:object_r:system_file:s0 "$MOD/disable" 2>/dev/null || true
echo "Nohello disabled; restarting zygote"
setprop ctl.restart zygote
EOF
chmod 700 "$ROLLBACK"

echo
echo "## enable"
rm -f "$MOD/disable"
echo "disable_removed=1"
echo "rollback=$ROLLBACK"

echo
echo "## restart zygote"
setprop ctl.restart zygote
