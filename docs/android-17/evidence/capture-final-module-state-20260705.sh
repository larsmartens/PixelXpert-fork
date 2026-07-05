#!/system/bin/sh
set -u

echo "## context"
date
id

echo
echo "## modules"
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  id=${d##*/}
  state=enabled
  [ ! -f "$d/disable" ] || state=disabled
  skip=no
  [ ! -f "$d/skip_mount" ] || skip=yes
  version="$(grep '^version=' "$d/module.prop" 2>/dev/null | head -1 | cut -d= -f2-)"
  versionCode="$(grep '^versionCode=' "$d/module.prop" 2>/dev/null | head -1 | cut -d= -f2-)"
  echo "$id state=$state skip_mount=$skip version=$version versionCode=$versionCode"
done | sort

echo
echo "## lsposed"
SQLITE=/data/adb/modules/PixelXpert/sqlite3
DB=/data/adb/lspd/config/modules_config.db
chmod 0755 "$SQLITE" 2>/dev/null || true
if [ -x "$SQLITE" ] && [ -f "$DB" ]; then
  "$SQLITE" "$DB" "select module_pkg_name,user_id,enabled,scope_request_blocked from modules_state where enabled=1 order by module_pkg_name;" 2>&1
  echo "-- PixelXpert scopes"
  "$SQLITE" "$DB" "select module_pkg_name,app_pkg_name,user_id from scope where module_pkg_name='sh.siava.pixelxpert' order by app_pkg_name;" 2>&1
  echo "-- system scopes"
  "$SQLITE" "$DB" "select module_pkg_name,app_pkg_name,user_id from scope where app_pkg_name='system' order by module_pkg_name;" 2>&1
fi
