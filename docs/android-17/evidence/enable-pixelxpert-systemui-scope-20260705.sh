#!/system/bin/sh
set -eu

PKG=sh.siava.pixelxpert
SCOPE=com.android.systemui
MOD=/data/adb/modules/PixelXpert
DB=/data/adb/lspd/config/modules_config.db
SQLITE="$MOD/sqlite3"
BASE=/data/adb/pixelxpert-stage
TS=$(date +%Y%m%d-%H%M%S)
WORK="$BASE/systemui-scope-$TS"
ROLLBACK="$WORK/rollback-pixelxpert-systemui-scope.sh"

echo "## preflight"
date
id
[ -x "$SQLITE" ] || { echo "missing sqlite: $SQLITE"; exit 1; }
[ -f "$DB" ] || { echo "missing LSPosed DB: $DB"; exit 1; }
[ -f "$MOD/disable" ] || { echo "PixelXpert module disable marker missing"; exit 1; }
[ -f "$MOD/skip_mount" ] || { echo "PixelXpert skip_mount marker missing"; exit 1; }
PMPATH="$(pm path "$PKG" 2>/dev/null | sed 's/package://g' | head -1)"
[ -n "$PMPATH" ] || { echo "PixelXpert package is not installed"; exit 1; }

mkdir -p "$WORK"
chmod 700 "$BASE" "$WORK" 2>/dev/null || true
cp -p "$DB" "$WORK/modules_config.db.before"
sha256sum "$WORK/modules_config.db.before"

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
pkill -f com.android.systemui 2>/dev/null || true
echo "Restored LSPosed DB and requested SystemUI restart"
EOF
chmod 700 "$ROLLBACK"

echo
echo "## add SystemUI scope"
"$SQLITE" "$DB" "insert or replace into modules (module_pkg_name, apk_path) values ('$PKG','$PMPATH');"
"$SQLITE" "$DB" "insert or replace into modules_state (module_pkg_name, user_id, enabled, scope_request_blocked) values ('$PKG',0,1,0);"
"$SQLITE" "$DB" "insert or ignore into scope (module_pkg_name, app_pkg_name, user_id) values ('$PKG','$SCOPE',0);"
"$SQLITE" "$DB" "pragma wal_checkpoint(full);"
chown root:root "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true
chmod 600 "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true
chcon u:object_r:system_file:s0 "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true

echo
echo "## verification before restart"
test -f "$MOD/disable" && echo "module_disable=present"
test -f "$MOD/skip_mount" && echo "skip_mount=present"
"$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where module_pkg_name='$PKG' order by app_pkg_name;"
echo "rollback=$ROLLBACK"

echo
echo "## restart SystemUI"
pkill -f com.android.systemui 2>/dev/null || true
