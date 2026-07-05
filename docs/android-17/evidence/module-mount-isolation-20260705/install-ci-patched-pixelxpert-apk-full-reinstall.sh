#!/system/bin/sh
set -u

ts="$(date +%Y%m%d-%H%M%S)"
stage="/data/adb/pixelxpert-stage/install-ci-patched-apk-full-reinstall-$ts"
pkg="sh.siava.pixelxpert"
mod="/data/adb/modules/PixelXpert"
staged_apk="${STAGED_APK:-/data/local/tmp/PixelXpert-ci-28756237299.apk}"
expected_sha="${EXPECTED_SHA:-17f97b0fcb86697a0e5f0a133fbd10dc36006997d4a85ebd3c38ee7339a65214}"
module_apk="$mod/system/priv-app/PixelXpert/PixelXpert.apk"
prefs_dir="/data/user_de/0/$pkg/shared_prefs"
prefs_file="$prefs_dir/${pkg}_preferences.xml"
tmp_restore="/data/local/tmp/PixelXpert-restore-base.apk"
mkdir -p "$stage"

[ -f "$staged_apk" ] || { echo "missing staged APK: $staged_apk"; exit 1; }
actual_sha="$(sha256sum "$staged_apk" | awk '{print $1}')"
[ "$actual_sha" = "$expected_sha" ] || {
  echo "APK hash mismatch: expected=$expected_sha actual=$actual_sha"
  exit 1
}

current_apk="$(pm path "$pkg" 2>/dev/null | sed 's/package://g' | head -1)"
[ -n "$current_apk" ] || { echo "current app is not installed"; exit 1; }

cp -p "$current_apk" "$stage/base.apk.before"
[ -f "$module_apk" ] && cp -p "$module_apk" "$stage/PixelXpert.module.apk.before"
[ -f "$prefs_file" ] && cp -p "$prefs_file" "$stage/${pkg}_preferences.xml.before"
tar -cpf "$stage/user0-data.tar" "/data/user/0/$pkg" "/data/user_de/0/$pkg" 2>/dev/null || true

cat > "$stage/rollback.sh" <<'EOF'
#!/system/bin/sh
set -u
stage="${1:-}"
pkg="sh.siava.pixelxpert"
module_apk="/data/adb/modules/PixelXpert/system/priv-app/PixelXpert/PixelXpert.apk"
tmp_restore="/data/local/tmp/PixelXpert-restore-base.apk"
[ -n "$stage" ] || {
  echo "usage: rollback.sh /data/adb/pixelxpert-stage/install-ci-patched-apk-full-reinstall-..."
  exit 2
}
[ -f "$stage/base.apk.before" ] || { echo "missing rollback APK"; exit 1; }
cp -p "$stage/base.apk.before" "$tmp_restore"
chown shell:shell "$tmp_restore" 2>/dev/null || true
chmod 0644 "$tmp_restore" 2>/dev/null || true
pm uninstall "$pkg" 2>/dev/null || true
pm install "$tmp_restore"
if [ -f "$stage/PixelXpert.module.apk.before" ]; then
  mkdir -p "$(dirname "$module_apk")"
  cp -p "$stage/PixelXpert.module.apk.before" "$module_apk"
  chmod 0644 "$module_apk" 2>/dev/null || true
fi
if [ -f "$stage/${pkg}_preferences.xml.before" ]; then
  mkdir -p "/data/user_de/0/$pkg/shared_prefs"
  cp -p "$stage/${pkg}_preferences.xml.before" "/data/user_de/0/$pkg/shared_prefs/${pkg}_preferences.xml"
  uid="$(stat -c '%u' "/data/user_de/0/$pkg" 2>/dev/null || echo '')"
  gid="$(stat -c '%g' "/data/user_de/0/$pkg" 2>/dev/null || echo '')"
  [ -n "$uid" ] && [ -n "$gid" ] && chown "$uid:$gid" "/data/user_de/0/$pkg/shared_prefs/${pkg}_preferences.xml" 2>/dev/null || true
fi
am force-stop "$pkg" 2>/dev/null || true
echo "Rolled back PixelXpert APK from $stage"
EOF
chmod 0755 "$stage/rollback.sh"

{
  echo "timestamp=$ts"
  echo "current_apk=$current_apk"
  sha256sum "$current_apk"
  [ -f "$module_apk" ] && sha256sum "$module_apk"
  [ -f "$prefs_file" ] && ls -lZ "$prefs_file"
  dumpsys package "$pkg" | grep -E "versionCode|versionName|sourceDir|signatures=" | head -30
} > "$stage/state-before.txt"

pm uninstall "$pkg"
if ! pm install "$staged_apk"; then
  echo "CI APK install failed; restoring previous APK"
  cp -p "$stage/base.apk.before" "$tmp_restore"
  chown shell:shell "$tmp_restore" 2>/dev/null || true
  chmod 0644 "$tmp_restore" 2>/dev/null || true
  pm install "$tmp_restore"
  [ -f "$stage/PixelXpert.module.apk.before" ] && cp -p "$stage/PixelXpert.module.apk.before" "$module_apk"
  exit 1
fi

mkdir -p "$(dirname "$module_apk")"
cp "$staged_apk" "$module_apk"
chmod 0644 "$module_apk" 2>/dev/null || true

if [ -f "$stage/${pkg}_preferences.xml.before" ]; then
  mkdir -p "$prefs_dir"
  cp -p "$stage/${pkg}_preferences.xml.before" "$prefs_file"
  uid="$(stat -c '%u' "/data/user_de/0/$pkg" 2>/dev/null || echo '')"
  gid="$(stat -c '%g' "/data/user_de/0/$pkg" 2>/dev/null || echo '')"
  [ -n "$uid" ] && [ -n "$gid" ] && chown "$uid:$gid" "$prefs_file" 2>/dev/null || true
fi

am force-stop "$pkg" 2>/dev/null || true

new_apk="$(pm path "$pkg" 2>/dev/null | sed 's/package://g' | head -1)"
{
  echo "timestamp=$ts"
  echo "rollback=$stage/rollback.sh $stage"
  echo "new_apk=$new_apk"
  [ -n "$new_apk" ] && sha256sum "$new_apk"
  sha256sum "$module_apk"
  [ -f "$prefs_file" ] && ls -lZ "$prefs_file"
  dumpsys package "$pkg" | grep -E "versionCode|versionName|sourceDir|signatures=" | head -30
} > "$stage/state-after.txt"

cat "$stage/state-after.txt"
