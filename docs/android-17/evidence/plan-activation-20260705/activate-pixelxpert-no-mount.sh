#!/system/bin/sh
set -eu

BB=/data/adb/ksu/bin/busybox
[ -x "$BB" ] || BB=busybox

STAGE=/data/adb/pixelxpert-stage/pixelxpert-no-mount-20260705
MOD=/data/adb/modules/PixelXpert
PKG=sh.siava.pixelxpert
LSPD_DB=
SQLITE=$MOD/sqlite3

mkdir -p "$STAGE"

echo "== preflight =="
date
id
getprop sys.boot_completed
if [ ! -d "$MOD" ]; then
  echo "PixelXpert module missing at $MOD"
  exit 1
fi
if [ ! -f "$MOD/system/priv-app/PixelXpert/PixelXpert.apk" ]; then
  echo "PixelXpert staged APK missing"
  exit 1
fi
if [ ! -x "$SQLITE" ]; then
  echo "PixelXpert sqlite3 missing or not executable"
  exit 1
fi

echo "== backups =="
for f in "$MOD/disable" "$MOD/skip_mount" "$MOD/a17_enable_privapp_mount" "$MOD/a17_enable_default_scopes" "$MOD/mount_error"; do
  if [ -e "$f" ]; then
    cp -af "$f" "$STAGE/$(basename "$f").bak"
    sha256sum "$f" 2>/dev/null || true
  fi
done

for candidate in /data/adb/lspd/config/modules_config.db /data/adb/*lsp*/config/modules_config.db; do
  [ -f "$candidate" ] || continue
  LSPD_DB="$candidate"
  break
done
if [ -n "$LSPD_DB" ]; then
  for f in "$LSPD_DB" "$LSPD_DB-wal" "$LSPD_DB-shm"; do
    [ -e "$f" ] || continue
    cp -af "$f" "$STAGE/$(basename "$f").bak"
    sha256sum "$f" "$STAGE/$(basename "$f").bak" 2>/dev/null || true
  done
fi

cat > "$STAGE/rollback.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
STAGE=/data/adb/pixelxpert-stage/pixelxpert-no-mount-20260705
MOD=/data/adb/modules/PixelXpert
touch "$MOD/disable"
touch "$MOD/skip_mount"
rm -f "$MOD/a17_enable_privapp_mount" "$MOD/mount_error"
if [ -f "$STAGE/modules_config.db.bak" ]; then
  for candidate in /data/adb/lspd/config/modules_config.db /data/adb/*lsp*/config/modules_config.db; do
    [ -f "$candidate" ] || continue
    for suffix in "" "-wal" "-shm"; do
      if [ -f "$STAGE/$(basename "$candidate$suffix").bak" ]; then
        cp -af "$STAGE/$(basename "$candidate$suffix").bak" "$candidate$suffix"
      fi
    done
    break
  done
fi
echo "rolled back PixelXpert to disabled no-mount state"
ROLLBACK
chmod 0700 "$STAGE/rollback.sh"
echo "rollback=$STAGE/rollback.sh"

echo "== enforce data-app/no-mount module mode =="
touch "$MOD/skip_mount"
rm -f "$MOD/a17_enable_privapp_mount" "$MOD/mount_error"
rm -f "$MOD/disable"

echo "== ensure data app installed =="
if ! pm path "$PKG" >/dev/null 2>&1; then
  pm install -r "$MOD/system/priv-app/PixelXpert/PixelXpert.apk"
fi
APK_PATH="$(pm path "$PKG" 2>/dev/null | "$BB" sed 's/package://g' | "$BB" head -1)"
if [ -z "$APK_PATH" ] || [ ! -f "$APK_PATH" ]; then
  echo "Unable to resolve installed PixelXpert APK path"
  exit 1
fi
echo "apk=$APK_PATH"

echo "== ensure LSPosed declared scopes =="
if [ -z "$LSPD_DB" ]; then
  echo "No LSPosed DB found"
  exit 1
fi
"$SQLITE" "$LSPD_DB" "insert or replace into modules (module_pkg_name, apk_path) values ('$PKG','$APK_PATH');"
"$SQLITE" "$LSPD_DB" "insert or replace into modules_state (module_pkg_name,user_id,enabled,scope_request_blocked) values ('$PKG',0,1,0);"
for scope in android com.android.settings com.android.systemui com.google.android.apps.nexuslauncher com.google.android.dialer com.rifsxd.ksunext "$PKG"; do
  "$SQLITE" "$LSPD_DB" "insert or ignore into scope (module_pkg_name, app_pkg_name, user_id) values ('$PKG','$scope',0);"
done
"$SQLITE" "$LSPD_DB" "delete from scope where module_pkg_name='$PKG' and app_pkg_name='system';" 2>/dev/null || true

echo "== resulting state =="
ls -laZ "$MOD"
"$SQLITE" "$LSPD_DB" "select module_pkg_name,apk_path from modules where module_pkg_name='$PKG';"
"$SQLITE" "$LSPD_DB" "select module_pkg_name,user_id,enabled,scope_request_blocked from modules_state where module_pkg_name='$PKG';"
"$SQLITE" "$LSPD_DB" "select app_pkg_name,user_id from scope where module_pkg_name='$PKG' order by app_pkg_name,user_id;"

echo "activation staged; reboot required for KSU service-script activation semantics"
