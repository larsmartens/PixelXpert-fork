#!/system/bin/sh
set -eu

DB=/data/adb/lspd/config/modules_config.db
SQLITE=/data/adb/modules/PixelXpert/sqlite3
BASE=/data/adb/pixelxpert-stage
TS=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BASE/root-stack-isolation-$TS"
ROLLBACK="$BACKUP_DIR/rollback-lsposed-system-scope.sh"

echo "## preflight"
date
id
[ -f "$DB" ] || { echo "missing DB: $DB"; exit 1; }
[ -x "$SQLITE" ] || { echo "missing sqlite: $SQLITE"; exit 1; }
mkdir -p "$BACKUP_DIR"
chmod 700 "$BASE" "$BACKUP_DIR" 2>/dev/null || true

echo "db=$DB"
ls -lZ "$DB"
sha256sum "$DB"
cp -p "$DB" "$BACKUP_DIR/modules_config.db.before"
sha256sum "$BACKUP_DIR/modules_config.db.before"

echo
echo "## system scope rows before"
"$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where app_pkg_name='system' order by module_pkg_name;"

cat > "$ROLLBACK" <<'EOF'
#!/system/bin/sh
set -eu
DB=/data/adb/lspd/config/modules_config.db
BACKUP_DIR=${0%/*}
cp -p "$BACKUP_DIR/modules_config.db.before" "$DB"
chown root:root "$DB"
chmod 600 "$DB"
restorecon "$DB" 2>/dev/null || true
echo "Restored $DB from $BACKUP_DIR/modules_config.db.before"
sha256sum "$DB"
EOF
chmod 700 "$ROLLBACK"

echo
echo "## update"
"$SQLITE" "$DB" "delete from scope where app_pkg_name='system';"
chown root:root "$DB"
chmod 600 "$DB"
restorecon "$DB" 2>/dev/null || true
sha256sum "$DB"

echo
echo "## system scope rows after"
"$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where app_pkg_name='system' order by module_pkg_name;"

echo
echo "rollback=$ROLLBACK"
