#!/system/bin/sh
set -eu

BB=/data/adb/ksu/bin/busybox
[ -x "$BB" ] || BB=busybox

echo "== identity =="
date
id
id -Z 2>/dev/null || true
getprop ro.build.version.sdk
getprop ro.build.fingerprint
getprop sys.boot_completed

echo
echo "== root stack =="
/data/adb/ksu/bin/ksud -V 2>/dev/null || true
uname -a
getprop ro.boot.verifiedbootstate
getprop ro.boot.flash.locked
getprop ro.boot.vbmeta.device_state

echo
echo "== modules =="
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  id="${d##*/}"
  state=enabled
  [ ! -e "$d/disable" ] || state=disabled
  skip=0
  [ -e "$d/skip_mount" ] && skip=1
  system=0
  [ -d "$d/system" ] && system=1
  ver="$("$BB" sed -n 's/^version=//p' "$d/module.prop" 2>/dev/null | "$BB" head -1)"
  printf '%s state=%s skip_mount=%s system=%s version=%s\n' "$id" "$state" "$skip" "$system" "$ver"
done | "$BB" sort

echo
echo "== PixelXpert package =="
pm path sh.siava.pixelxpert 2>/dev/null || true
cmd package resolve-activity --brief sh.siava.pixelxpert 2>/dev/null || true
dumpsys package sh.siava.pixelxpert 2>/dev/null | "$BB" grep -E 'versionCode=|versionName=|codePath=|targetSdk=|granted=true|POST_NOTIFICATIONS|ACCESS_LOCAL_NETWORK|QUERY_ALL_PACKAGES' | "$BB" head -80 || true

echo
echo "== LSPosed PixelXpert rows =="
LSPD_DB=
for candidate in /data/adb/lspd/config/modules_config.db /data/adb/*lsp*/config/modules_config.db; do
  [ -f "$candidate" ] || continue
  LSPD_DB="$candidate"
  break
done
echo "db=$LSPD_DB"
SQLITE=/data/adb/modules/PixelXpert/sqlite3
if [ -n "$LSPD_DB" ] && [ -x "$SQLITE" ]; then
  "$SQLITE" "$LSPD_DB" "select module_pkg_name, apk_path from modules where module_pkg_name='sh.siava.pixelxpert';" 2>/dev/null || true
  "$SQLITE" "$LSPD_DB" "select module_pkg_name,user_id,enabled,scope_request_blocked from modules_state where module_pkg_name='sh.siava.pixelxpert';" 2>/dev/null || true
  "$SQLITE" "$LSPD_DB" "select app_pkg_name,user_id from scope where module_pkg_name='sh.siava.pixelxpert' order by app_pkg_name,user_id;" 2>/dev/null || true
fi

echo
echo "== Hybrid Mount =="
/data/adb/ksu/bin/ksud module list 2>/dev/null | "$BB" grep -Ei '"id":"([^"]*(hybrid|overlay|magic|mountify|susfs)[^"]*)"' || true
"$BB" find /data/adb/hybrid-mount -maxdepth 2 -print 2>/dev/null | "$BB" head -120 || true
if [ -f /data/adb/hybrid-mount/config.toml ]; then
  "$BB" sed -n '1,160p' /data/adb/hybrid-mount/config.toml
fi
if command -v hybrid-mount >/dev/null 2>&1; then
  hybrid-mount daemon status 2>/dev/null || true
fi

echo
echo "== AdGuard cert module =="
if [ -d /data/adb/modules/adguardcert ]; then
  "$BB" find /data/adb/modules/adguardcert -maxdepth 8 -print 2>/dev/null | "$BB" head -160
  "$BB" sed -n '1,120p' /data/adb/modules/adguardcert/module.prop 2>/dev/null || true
fi
mount 2>/dev/null | "$BB" grep -Ei 'adguard|cacerts|overlay|hybrid|magic|kasumi|/data/adb/modules' | "$BB" head -160 || true

echo
echo "== recent crash markers =="
"$BB" ls -lt /data/system/dropbox/system_server_crash* /data/system/dropbox/system_server_watchdog* /data/system/dropbox/system_server_pre_watchdog* /data/system/dropbox/system_server_anr* 2>/dev/null | "$BB" head -20 || true
"$BB" ls -lt /data/tombstones 2>/dev/null | "$BB" head -20 || true
