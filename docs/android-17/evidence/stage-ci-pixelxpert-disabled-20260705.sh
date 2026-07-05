#!/system/bin/sh
set -eu

ZIP="/data/local/tmp/px-final-ci-28738543788/PixelXpert.zip"
CHANGE_ID="ci-50106ce9-20260705"
STAGE="/data/adb/pixelxpert-stage/$CHANGE_ID"
LIVE="/data/adb/modules/PixelXpert"
NEW="$STAGE/new/PixelXpert"
BACKUP="$STAGE/backup/PixelXpert.before"

if [ ! -f "$ZIP" ]; then
  echo "missing staged zip: $ZIP" >&2
  exit 1
fi

rm -rf "$STAGE/new"
mkdir -p "$STAGE/new" "$STAGE/backup"

sha256sum "$ZIP" > "$STAGE/PixelXpert.zip.sha256"

if [ -d "$LIVE" ] && [ ! -d "$BACKUP" ]; then
  cp -a "$LIVE" "$BACKUP"
fi

unzip -q "$ZIP" -d "$NEW"
touch "$NEW/disable"
touch "$NEW/skip_mount"

cat > "$STAGE/rollback-restore-pixelxpert.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
LIVE="/data/adb/modules/PixelXpert"
BACKUP="/data/adb/pixelxpert-stage/ci-50106ce9-20260705/backup/PixelXpert.before"
if [ ! -d "$BACKUP" ]; then
  echo "missing backup: $BACKUP" >&2
  exit 1
fi
rm -rf "$LIVE"
cp -a "$BACKUP" "$LIVE"
touch "$LIVE/disable"
touch "$LIVE/skip_mount"
echo "restored PixelXpert backup and kept module disabled"
ROLLBACK
chmod 0700 "$STAGE/rollback-restore-pixelxpert.sh"

rm -rf "$LIVE"
cp -a "$NEW" "$LIVE"
touch "$LIVE/disable"
touch "$LIVE/skip_mount"

echo "zip_sha256=$(cut -d ' ' -f 1 "$STAGE/PixelXpert.zip.sha256")"
echo "live_module=$LIVE"
echo "rollback=$STAGE/rollback-restore-pixelxpert.sh"
ls -l "$LIVE/disable" "$LIVE/skip_mount"
sed -n '1,20p' "$LIVE/module.prop"
