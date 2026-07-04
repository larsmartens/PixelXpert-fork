#!/system/bin/sh
set -eu

PKG=sh.siava.pixelxpert
MOD=/data/adb/modules/PixelXpert
ZIP=/data/local/tmp/PixelXpert-28721984741.zip
DB=/data/adb/lspd/config/modules_config.db
SQLITE="$MOD/sqlite3"
BASE=/data/adb/pixelxpert-stage
TS=$(date +%Y%m%d-%H%M%S)
WORK="$BASE/data-app-self-scope-$TS"
ROLLBACK="$WORK/rollback-pixelxpert-data-app-self-scope.sh"

echo "## preflight"
date
id
[ -f "$ZIP" ] || { echo "missing zip: $ZIP"; exit 1; }
[ -f "$DB" ] || { echo "missing LSPosed DB: $DB"; exit 1; }
mkdir -p "$WORK"
chmod 700 "$BASE" "$WORK" 2>/dev/null || true

echo "zip=$ZIP"
sha256sum "$ZIP"
echo "module=$MOD"
if [ -d "$MOD" ]; then
  ls -lZ "$MOD" | head -n 80
  tar -C /data/adb/modules -cpf "$WORK/PixelXpert.module.before.tar" PixelXpert
  sha256sum "$WORK/PixelXpert.module.before.tar"
fi

PM_BEFORE="$(pm path "$PKG" 2>/dev/null | sed 's/package://g' | head -1)"
printf '%s\n' "$PM_BEFORE" > "$WORK/pm_path.before"
echo "pm_path_before=$PM_BEFORE"
cp -p "$DB" "$WORK/modules_config.db.before"
sha256sum "$WORK/modules_config.db.before"

cat > "$ROLLBACK" <<'EOF'
#!/system/bin/sh
set -eu
PKG=sh.siava.pixelxpert
MOD=/data/adb/modules/PixelXpert
DB=/data/adb/lspd/config/modules_config.db
BACKUP_DIR=${0%/*}

if [ -f "$BACKUP_DIR/modules_config.db.before" ]; then
  cp -p "$BACKUP_DIR/modules_config.db.before" "$DB"
  rm -f "$DB-wal" "$DB-shm"
  chown root:root "$DB"
  chmod 600 "$DB"
  chcon u:object_r:system_file:s0 "$DB" 2>/dev/null || true
fi

PM_BEFORE="$(cat "$BACKUP_DIR/pm_path.before" 2>/dev/null || true)"
if [ -z "$PM_BEFORE" ]; then
  pm uninstall "$PKG" >/dev/null 2>&1 || true
else
  echo "Preserving pre-existing package path: $PM_BEFORE"
fi

if [ -f "$BACKUP_DIR/PixelXpert.module.before.tar" ]; then
  rm -rf "$MOD"
  mkdir -p /data/adb/modules
  tar -C /data/adb/modules -xpf "$BACKUP_DIR/PixelXpert.module.before.tar"
  touch "$MOD/disable"
fi

echo "Rollback complete"
test -f "$MOD/disable" && echo "PixelXpert module disabled"
pm path "$PKG" 2>/dev/null || true
ls -lZ "$DB" 2>/dev/null || true
EOF
chmod 700 "$ROLLBACK"

echo
echo "## replace module while disabled"
mkdir -p "$MOD"
touch "$MOD/disable"
find "$MOD" -mindepth 1 ! -name disable -exec rm -rf {} + 2>/dev/null || true
unzip -o "$ZIP" -d "$MOD" >/dev/null
touch "$MOD/disable"
touch "$MOD/skip_mount"
rm -f "$MOD/mount_error" "$MOD/remove" "$MOD/a17_enable_privapp_mount" "$MOD/a17_enable_default_scopes"
chmod 755 "$MOD/customize.sh" "$MOD/service.sh" "$MOD/sqlite3"
chown -R root:root "$MOD"
find "$MOD" -type d -exec chmod 755 {} +
find "$MOD" -type f -exec chmod 644 {} +
chmod 755 "$MOD/customize.sh" "$MOD/service.sh" "$MOD/sqlite3"

echo
echo "## install data app"
APK="$MOD/system/priv-app/PixelXpert/PixelXpert.apk"
INSTALL_APK=/data/local/tmp/PixelXpert-install-28721984741.apk
ls -lZ "$APK"
sha256sum "$APK"
cp -f "$APK" "$INSTALL_APK"
chown shell:shell "$INSTALL_APK" 2>/dev/null || true
chmod 644 "$INSTALL_APK"
chcon u:object_r:shell_data_file:s0 "$INSTALL_APK" 2>/dev/null || true
ls -lZ "$INSTALL_APK"
pm install -r "$INSTALL_APK"
PMPATH="$(pm path "$PKG" 2>/dev/null | sed 's/package://g' | head -1)"
echo "pm_path_after=$PMPATH"
[ -n "$PMPATH" ] || { echo "package install did not resolve"; exit 1; }

echo
echo "## activate self scope"
SQLITE="$MOD/sqlite3"
"$SQLITE" "$DB" "insert or replace into modules (module_pkg_name, apk_path) values ('$PKG','$PMPATH');"
"$SQLITE" "$DB" "insert or replace into modules_state (module_pkg_name, user_id, enabled, scope_request_blocked) values ('$PKG',0,1,0);"
"$SQLITE" "$DB" "delete from scope where module_pkg_name='$PKG';"
"$SQLITE" "$DB" "insert or ignore into scope (module_pkg_name, app_pkg_name, user_id) values ('$PKG','$PKG',0);"
"$SQLITE" "$DB" "pragma wal_checkpoint(full);"
chown root:root "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true
chmod 600 "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true
chcon u:object_r:system_file:s0 "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true

echo
echo "## verification"
test -f "$MOD/disable" && echo "module_disable=present"
test -f "$MOD/skip_mount" && echo "skip_mount=present"
pm path "$PKG" 2>/dev/null
"$SQLITE" "$DB" "select module_pkg_name, apk_path from modules where module_pkg_name='$PKG';"
"$SQLITE" "$DB" "select module_pkg_name, user_id, enabled, scope_request_blocked from modules_state where module_pkg_name='$PKG';"
"$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where module_pkg_name='$PKG';"
ls -lZ "$DB" "$DB-wal" "$DB-shm" 2>/dev/null || true
echo "rollback=$ROLLBACK"
