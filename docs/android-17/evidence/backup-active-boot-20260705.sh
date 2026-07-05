#!/system/bin/sh
set -eu

BASE=/data/adb/pixelxpert-stage
TS=$(date +%Y%m%d-%H%M%S)
WORK="$BASE/bluspark-r266-backup-$TS"
SLOT="$(getprop ro.boot.slot_suffix)"
BOOT="/dev/block/by-name/boot${SLOT}"
ROLLBACK="$WORK/rollback-restore-boot${SLOT}.sh"

echo "## context"
date
id
uname -a
echo "slot=$SLOT"
echo "boot=$BOOT"
[ -e "$BOOT" ] || { echo "missing active boot partition"; exit 1; }
mkdir -p "$WORK"
chmod 700 "$BASE" "$WORK" 2>/dev/null || true

echo
echo "## backup"
dd if="$BOOT" of="$WORK/boot${SLOT}.before.img" bs=4M status=none
sync
ls -lZ "$WORK/boot${SLOT}.before.img"
sha256sum "$WORK/boot${SLOT}.before.img" | tee "$WORK/boot${SLOT}.before.img.sha256"

cat > "$ROLLBACK" <<EOF
#!/system/bin/sh
set -eu
BOOT="$BOOT"
IMG="$WORK/boot${SLOT}.before.img"
[ -f "\$IMG" ] || { echo "missing backup image: \$IMG"; exit 1; }
sha256sum -c "$WORK/boot${SLOT}.before.img.sha256"
dd if="\$IMG" of="\$BOOT" bs=4M conv=fsync
sync
echo "Restored \$BOOT from \$IMG"
EOF
chmod 700 "$ROLLBACK"
echo "rollback=$ROLLBACK"
