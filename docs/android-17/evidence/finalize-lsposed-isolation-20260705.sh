#!/system/bin/sh
set -eu

DB=/data/adb/lspd/config/modules_config.db
SQLITE=/data/adb/modules/PixelXpert/sqlite3
BACKUP_DIR=/data/adb/pixelxpert-stage/root-stack-isolation-20260705-003110
ROLLBACK="$BACKUP_DIR/rollback-lsposed-system-scope.sh"

echo "## context"
date
id

echo
echo "## sqlite checkpoint"
"$SQLITE" "$DB" "pragma journal_mode; pragma wal_checkpoint(full); select module_pkg_name, app_pkg_name, user_id from scope where app_pkg_name='system' order by module_pkg_name;"

echo
echo "## labels"
for f in "$DB" "$DB-wal" "$DB-shm" "$BACKUP_DIR/modules_config.db.before"; do
  [ -e "$f" ] || continue
  chown root:root "$f"
  chmod 600 "$f"
  chcon u:object_r:system_file:s0 "$f" 2>/dev/null || true
done

cat > "$ROLLBACK" <<'EOF'
#!/system/bin/sh
set -eu
DB=/data/adb/lspd/config/modules_config.db
BACKUP_DIR=${0%/*}
cp -p "$BACKUP_DIR/modules_config.db.before" "$DB"
rm -f "$DB-wal" "$DB-shm"
chown root:root "$DB"
chmod 600 "$DB"
chcon u:object_r:system_file:s0 "$DB" 2>/dev/null || true
echo "Restored $DB from $BACKUP_DIR/modules_config.db.before"
sha256sum "$DB"
ls -lZ "$DB"
EOF
chmod 700 "$ROLLBACK"
chcon u:object_r:system_file:s0 "$ROLLBACK" 2>/dev/null || true

echo
echo "## files"
ls -lZ "$DB" "$DB-wal" "$DB-shm" "$BACKUP_DIR/modules_config.db.before" "$ROLLBACK" 2>/dev/null || true
sha256sum "$DB" "$DB-wal" "$DB-shm" "$BACKUP_DIR/modules_config.db.before" 2>/dev/null || true

echo
echo "## rollback"
echo "$ROLLBACK"
