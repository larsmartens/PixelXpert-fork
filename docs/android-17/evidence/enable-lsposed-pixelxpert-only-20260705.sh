#!/system/bin/sh
set -eu

PKG=sh.siava.pixelxpert
SYSTEMUI=com.android.systemui
PX_MOD=/data/adb/modules/PixelXpert
LSP_MOD=/data/adb/modules/zygisk_lsposed
DB=/data/adb/lspd/config/modules_config.db
SQLITE=$PX_MOD/sqlite3
BASE=/data/adb/pixelxpert-stage
STAMP=lsposed-pixelxpert-only-20260705-$(date +%H%M%S)
WORK=$BASE/$STAMP
ROLLBACK=$WORK/rollback-disable-lsposed-restore-db.sh

echo "## preflight"
date
id
[ -d "$PX_MOD" ] || { echo "missing PixelXpert module: $PX_MOD"; exit 1; }
[ -d "$LSP_MOD" ] || { echo "missing LSPosed module: $LSP_MOD"; exit 1; }
[ -f "$DB" ] || { echo "missing LSPosed DB: $DB"; exit 1; }
[ -f "$PX_MOD/disable" ] || { echo "PixelXpert KSU disable marker missing"; exit 1; }
[ -f "$PX_MOD/skip_mount" ] || { echo "PixelXpert skip_mount marker missing"; exit 1; }
chmod 0755 "$SQLITE"
[ -x "$SQLITE" ] || { echo "sqlite unavailable: $SQLITE"; exit 1; }

PMPATH="$(pm path "$PKG" 2>/dev/null | sed 's/package://g' | head -1)"
[ -n "$PMPATH" ] || { echo "PixelXpert package is not installed as data app"; exit 1; }
echo "pm_path=$PMPATH"

mkdir -p "$WORK"
chmod 0700 "$BASE" "$WORK" 2>/dev/null || true

echo
echo "## checkpoint and backup"
"$SQLITE" "$DB" "pragma journal_mode; pragma wal_checkpoint(full);"
cp -p "$DB" "$WORK/modules_config.db.before"
[ ! -f "$DB-wal" ] || cp -p "$DB-wal" "$WORK/modules_config.db-wal.before"
[ ! -f "$DB-shm" ] || cp -p "$DB-shm" "$WORK/modules_config.db-shm.before"
sha256sum "$WORK"/modules_config.db.before* 2>/dev/null || true

cat > "$ROLLBACK" <<EOF
#!/system/bin/sh
set -eu
DB=$DB
LSP_MOD=$LSP_MOD
BACKUP_DIR=\${0%/*}
touch "\$LSP_MOD/disable"
if [ -f "\$BACKUP_DIR/modules_config.db.before" ]; then
  cp -p "\$BACKUP_DIR/modules_config.db.before" "\$DB"
  rm -f "\$DB-wal" "\$DB-shm"
fi
chown root:root "\$DB" 2>/dev/null || true
chmod 0600 "\$DB" 2>/dev/null || true
chcon u:object_r:system_file:s0 "\$DB" 2>/dev/null || true
echo "LSPosed disabled and DB restored from \$BACKUP_DIR"
EOF
chmod 0700 "$ROLLBACK"

echo
echo "## sanitize LSPosed DB"
"$SQLITE" "$DB" "update modules_state set enabled=0 where module_pkg_name <> '$PKG';"
"$SQLITE" "$DB" "insert or replace into modules (module_pkg_name, apk_path) values ('$PKG','$PMPATH');"
"$SQLITE" "$DB" "insert or replace into modules_state (module_pkg_name, user_id, enabled, scope_request_blocked) values ('$PKG',0,1,0);"
"$SQLITE" "$DB" "delete from scope where app_pkg_name='system';"
"$SQLITE" "$DB" "delete from scope where module_pkg_name='$PKG';"
"$SQLITE" "$DB" "insert or ignore into scope (module_pkg_name, app_pkg_name, user_id) values ('$PKG','$PKG',0);"
"$SQLITE" "$DB" "insert or ignore into scope (module_pkg_name, app_pkg_name, user_id) values ('$PKG','$SYSTEMUI',0);"
"$SQLITE" "$DB" "pragma wal_checkpoint(full);"
chown root:root "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true
chmod 0600 "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true
chcon u:object_r:system_file:s0 "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true

echo
echo "## enable LSPosed module"
rm -f "$LSP_MOD/disable" "$LSP_MOD/remove" 2>/dev/null || true
touch "$PX_MOD/disable" "$PX_MOD/skip_mount"
rm -f "$PX_MOD/remove" "$PX_MOD/a17_enable_privapp_mount" "$PX_MOD/a17_enable_default_scopes" "$PX_MOD/mount_error" 2>/dev/null || true

echo
echo "## verification"
test -f "$LSP_MOD/disable" && echo "lsposed_disable=present" || echo "lsposed_disable=absent"
test -f "$PX_MOD/disable" && echo "pixelxpert_module_disable=present"
test -f "$PX_MOD/skip_mount" && echo "pixelxpert_skip_mount=present"
echo "-- enabled module states"
"$SQLITE" "$DB" "select module_pkg_name, user_id, enabled, scope_request_blocked from modules_state where enabled=1 order by module_pkg_name;"
echo "-- PixelXpert scopes"
"$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where module_pkg_name='$PKG' order by app_pkg_name;"
echo "-- system scopes"
"$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where app_pkg_name='system' order by module_pkg_name;"
echo "rollback=$ROLLBACK"
