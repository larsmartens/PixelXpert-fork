#!/system/bin/sh
set -eu

BASE=/data/adb/pixelxpert-stage
STAMP=restore-session-modules-20260705-$(date +%H%M%S)
WORK=$BASE/$STAMP
ROLLBACK=$WORK/rollback-disable-restored-modules.sh
MODULES=/data/adb/modules
GPHOTOS_ZIP=/data/local/tmp/GPhotosUnlimited-v3.zip

ENABLE_IDS="ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone rvmm-zygisk-mount unlimitedphotos zygisk-detach zygisk_nohello zygisk_lsposed"
KEEP_DISABLED_IDS="PixelXpert rezygisk zygisk_thanox magisk-captive-manager youtube-morphe-jhc"

echo "## preflight"
date
id
[ -d "$MODULES" ] || { echo "missing $MODULES"; exit 1; }
[ -f "$GPHOTOS_ZIP" ] || { echo "missing $GPHOTOS_ZIP"; exit 1; }

mkdir -p "$WORK"
chmod 0700 "$BASE" "$WORK" 2>/dev/null || true

echo
echo "## backup current state"
for id in $ENABLE_IDS $KEEP_DISABLED_IDS; do
  if [ -d "$MODULES/$id" ]; then
    state=enabled
    [ ! -f "$MODULES/$id/disable" ] || state=disabled
    echo "$id $state" >> "$WORK/module-state.before"
    sed -n '1,80p' "$MODULES/$id/module.prop" > "$WORK/$id.module.prop.before" 2>/dev/null || true
  fi
done
if [ -d "$MODULES/unlimitedphotos" ]; then
  tar -C "$MODULES" -cpf "$WORK/unlimitedphotos.before.tar" unlimitedphotos
  sha256sum "$WORK/unlimitedphotos.before.tar"
fi

cat > "$ROLLBACK" <<EOF
#!/system/bin/sh
set -eu
MODULES=$MODULES
BACKUP_DIR=\${0%/*}
for id in $ENABLE_IDS; do
  [ -d "\$MODULES/\$id" ] && touch "\$MODULES/\$id/disable"
done
if [ -f "\$BACKUP_DIR/unlimitedphotos.before.tar" ]; then
  rm -rf "\$MODULES/unlimitedphotos"
  tar -C "\$MODULES" -xpf "\$BACKUP_DIR/unlimitedphotos.before.tar"
fi
touch "\$MODULES/PixelXpert/disable" "\$MODULES/PixelXpert/skip_mount" 2>/dev/null || true
echo "Restored module disable state and Unlimited Photos backup from \$BACKUP_DIR"
EOF
chmod 0700 "$ROLLBACK"

echo
echo "## update Unlimited Photos"
rm -rf "$MODULES/unlimitedphotos"
mkdir -p "$MODULES/unlimitedphotos"
unzip -o "$GPHOTOS_ZIP" -d "$MODULES/unlimitedphotos" >/dev/null
chown -R root:root "$MODULES/unlimitedphotos" 2>/dev/null || true
find "$MODULES/unlimitedphotos" -type d -exec chmod 0755 {} +
find "$MODULES/unlimitedphotos" -type f -exec chmod 0644 {} +
for f in customize.sh post-fs-data.sh service.sh uninstall.sh; do
  [ -f "$MODULES/unlimitedphotos/$f" ] && chmod 0755 "$MODULES/unlimitedphotos/$f"
done
restorecon -R "$MODULES/unlimitedphotos" 2>/dev/null || true

echo
echo "## restore selected modules"
for id in $ENABLE_IDS; do
  if [ -d "$MODULES/$id" ]; then
    rm -f "$MODULES/$id/disable" "$MODULES/$id/remove"
    echo "enabled $id"
  else
    echo "missing $id"
  fi
done

echo
echo "## keep explicit exceptions disabled"
for id in $KEEP_DISABLED_IDS; do
  if [ -d "$MODULES/$id" ]; then
    touch "$MODULES/$id/disable"
    echo "disabled $id"
  fi
done
touch "$MODULES/PixelXpert/skip_mount" 2>/dev/null || true

echo
echo "## final module state"
for id in $ENABLE_IDS $KEEP_DISABLED_IDS playintegrityfix tricky_store zygisksu; do
  [ -d "$MODULES/$id" ] || continue
  state=enabled
  [ ! -f "$MODULES/$id/disable" ] || state=disabled
  version="$(grep '^version=' "$MODULES/$id/module.prop" 2>/dev/null | head -1 | cut -d= -f2-)"
  versionCode="$(grep '^versionCode=' "$MODULES/$id/module.prop" 2>/dev/null | head -1 | cut -d= -f2-)"
  echo "$id state=$state version=$version versionCode=$versionCode"
done
echo "rollback=$ROLLBACK"
