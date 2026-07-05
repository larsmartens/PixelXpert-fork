#!/system/bin/sh
set -u

PKG=sh.siava.pixelxpert
PX_MOD=/data/adb/modules/PixelXpert
LSP_MOD=/data/adb/modules/zygisk_lsposed
DB=/data/adb/lspd/config/modules_config.db
SQLITE=$PX_MOD/sqlite3

echo "## context"
date
id
echo "boot_completed=$(getprop sys.boot_completed)"
echo "bootanim=$(getprop init.svc.bootanim)"
echo "system_server=$(pidof system_server 2>/dev/null || true)"
echo "systemui=$(pidof com.android.systemui 2>/dev/null || true)"
echo "pixelxpert=$(pidof "$PKG" 2>/dev/null || true)"
dumpsys window 2>/dev/null | grep -E "mCurrentFocus|mFocusedApp|mShowingLockscreen|mDreamingLockscreen" | head -n 20

echo
echo "## module markers"
for f in \
  "$LSP_MOD/disable" \
  "$PX_MOD/disable" \
  "$PX_MOD/skip_mount" \
  "$PX_MOD/a17_enable_privapp_mount" \
  "$PX_MOD/a17_enable_default_scopes"; do
  if [ -e "$f" ]; then
    echo "present:$f"
    ls -lZ "$f" 2>/dev/null
  else
    echo "absent:$f"
  fi
done

echo
echo "## package"
pm path "$PKG" 2>/dev/null || true
dumpsys package "$PKG" 2>/dev/null | grep -E "versionCode|versionName|targetSdk|codePath|resourcePath" | head -n 50

echo
echo "## lsposed db"
chmod 0755 "$SQLITE" 2>/dev/null || true
if [ -x "$SQLITE" ] && [ -f "$DB" ]; then
  echo "-- enabled modules"
  "$SQLITE" "$DB" "select module_pkg_name,user_id,enabled,scope_request_blocked from modules_state where enabled=1 order by module_pkg_name;" 2>&1
  echo "-- PixelXpert module path"
  "$SQLITE" "$DB" "select module_pkg_name,apk_path from modules where module_pkg_name='$PKG';" 2>&1
  echo "-- PixelXpert scopes"
  "$SQLITE" "$DB" "select module_pkg_name,app_pkg_name,user_id from scope where module_pkg_name='$PKG' order by app_pkg_name;" 2>&1
  echo "-- system scopes"
  "$SQLITE" "$DB" "select module_pkg_name,app_pkg_name,user_id from scope where app_pkg_name='system' order by module_pkg_name;" 2>&1
fi

echo
echo "## dropbox"
ls -1t /data/system/dropbox/system_server_* 2>/dev/null | head -n 20

echo
echo "## tombstones"
ls -lt /data/tombstones 2>/dev/null | head -n 20

echo
echo "## targeted logcat"
logcat -d -t 3500 2>/dev/null | grep -E "PixelXpert|sh.siava.pixelxpert|LSPosed|lspd|l53202|system_server_pre_watchdog|system_server_watchdog|Watchdog|ANR in system|avc: denied" | tail -n 300
