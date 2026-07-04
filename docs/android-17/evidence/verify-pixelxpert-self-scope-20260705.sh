#!/system/bin/sh
set -u

PKG=sh.siava.pixelxpert
MOD=/data/adb/modules/PixelXpert
DB=/data/adb/lspd/config/modules_config.db
SQLITE="$MOD/sqlite3"

echo "## context"
date
id
getprop sys.boot_completed
getprop init.svc.bootanim
ps -A | grep system_server | head -n 1
pidof "$PKG" 2>/dev/null || true
dumpsys window 2>/dev/null | grep -E "mCurrentFocus|mFocusedApp|mDreamingLockscreen" | head -n 20

echo
echo "## package"
pm path "$PKG" 2>/dev/null || true
pm list packages -U "$PKG" 2>/dev/null || true
dumpsys package "$PKG" 2>/dev/null | grep -E "versionCode|versionName|firstInstallTime|lastUpdateTime|codePath|resourcePath" | head -n 40

echo
echo "## module markers"
for f in "$MOD/disable" "$MOD/skip_mount" "$MOD/mount_error" "$MOD/a17_enable_privapp_mount" "$MOD/a17_enable_default_scopes" "$MOD/system/priv-app/PixelXpert/PixelXpert.apk"; do
  if [ -e "$f" ]; then
    ls -lZ "$f" 2>/dev/null
    sha256sum "$f" 2>/dev/null
  else
    echo "missing $f"
  fi
done

echo
echo "## lsposed-pixelxpert"
if [ -x "$SQLITE" ] && [ -f "$DB" ]; then
  "$SQLITE" "$DB" "select module_pkg_name, apk_path from modules where module_pkg_name='$PKG';" 2>&1
  "$SQLITE" "$DB" "select module_pkg_name, user_id, enabled, scope_request_blocked from modules_state where module_pkg_name='$PKG';" 2>&1
  "$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where module_pkg_name='$PKG';" 2>&1
  echo "-- system scopes"
  "$SQLITE" "$DB" "select module_pkg_name, app_pkg_name, user_id from scope where app_pkg_name='system' order by module_pkg_name;" 2>&1
fi

echo
echo "## dropbox-system-server-latest"
ls -1t /data/system/dropbox/system_server_* 2>/dev/null | head -n 12

echo
echo "## tombstones"
ls -lZ /data/tombstones 2>/dev/null | tail -n 20

echo
echo "## targeted-logcat"
logcat -d -t 2500 2>/dev/null | grep -E "PixelXpert|sh.siava.pixelxpert|LSPosedFramework: \\(sh.siava.pixelxpert\\)|LSPosedFramework: \\(system\\)|l53202|system_server_pre_watchdog|system_server_watchdog|Watchdog|ANR in system|avc: denied" | tail -n 250
