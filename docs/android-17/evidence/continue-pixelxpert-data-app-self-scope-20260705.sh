#!/system/bin/sh
set -eu

PKG=sh.siava.pixelxpert
MOD=/data/adb/modules/PixelXpert
DB=/data/adb/lspd/config/modules_config.db
WORK=/data/adb/pixelxpert-stage/data-app-self-scope-20260705-010022
APK="$MOD/system/priv-app/PixelXpert/PixelXpert.apk"
INSTALL_APK=/data/local/tmp/PixelXpert-install-28721984741.apk

echo "## context"
date
id
[ -f "$WORK/modules_config.db.before" ] || { echo "missing DB backup: $WORK/modules_config.db.before"; exit 1; }
[ -f "$WORK/rollback-pixelxpert-data-app-self-scope.sh" ] || { echo "missing rollback: $WORK/rollback-pixelxpert-data-app-self-scope.sh"; exit 1; }
[ -f "$APK" ] || { echo "missing APK: $APK"; exit 1; }
[ -x "$MOD/sqlite3" ] || chmod 755 "$MOD/sqlite3"
SQLITE="$MOD/sqlite3"

echo
echo "## module markers"
touch "$MOD/disable"
touch "$MOD/skip_mount"
rm -f "$MOD/mount_error" "$MOD/remove" "$MOD/a17_enable_privapp_mount" "$MOD/a17_enable_default_scopes"
ls -lZ "$MOD/disable" "$MOD/skip_mount" "$APK"
sha256sum "$APK"

echo
echo "## install from package-manager-readable path"
cp -f "$APK" "$INSTALL_APK"
chown shell:shell "$INSTALL_APK" 2>/dev/null || true
chmod 644 "$INSTALL_APK"
chcon u:object_r:shell_data_file:s0 "$INSTALL_APK" 2>/dev/null || true
ls -lZ "$INSTALL_APK"
sha256sum "$INSTALL_APK"
pm install -r "$INSTALL_APK"
PMPATH="$(pm path "$PKG" 2>/dev/null | sed 's/package://g' | head -1)"
echo "pm_path_after=$PMPATH"
[ -n "$PMPATH" ] || { echo "package install did not resolve"; exit 1; }

echo
echo "## activate LSPosed self scope only"
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
echo "rollback=$WORK/rollback-pixelxpert-data-app-self-scope.sh"
