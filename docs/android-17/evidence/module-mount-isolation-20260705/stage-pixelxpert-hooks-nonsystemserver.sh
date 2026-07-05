#!/system/bin/sh
set -u

ts="$(date +%Y%m%d-%H%M%S)"
stage="/data/adb/pixelxpert-stage/pixelxpert-hooks-nonsystemserver-$ts"
db="/data/adb/lspd/config/modules_config.db"
sqlite="/data/adb/modules/PixelXpert/sqlite3"
pkg="sh.siava.pixelxpert"
mkdir -p "$stage"

[ -f "$db" ] || { echo "missing LSPosed DB: $db"; exit 1; }
[ -x "$sqlite" ] || chmod 0755 "$sqlite" 2>/dev/null || true
[ -x "$sqlite" ] || { echo "missing executable sqlite: $sqlite"; exit 1; }

cp -p "$db" "$stage/modules_config.db.before"
[ -f "$db-wal" ] && cp -p "$db-wal" "$stage/modules_config.db-wal.before"
[ -f "$db-shm" ] && cp -p "$db-shm" "$stage/modules_config.db-shm.before"

cat > "$stage/rollback.sh" <<'EOF'
#!/system/bin/sh
set -u
stage="${1:-}"
[ -n "$stage" ] || {
  echo "usage: rollback.sh /data/adb/pixelxpert-stage/pixelxpert-hooks-nonsystemserver-..."
  exit 2
}
db="/data/adb/lspd/config/modules_config.db"
setprop persist.pixelxpert.disable_hooks 1
[ -f "$stage/modules_config.db.before" ] && cp -p "$stage/modules_config.db.before" "$db"
[ -f "$stage/modules_config.db-wal.before" ] && cp -p "$stage/modules_config.db-wal.before" "$db-wal" || rm -f "$db-wal"
[ -f "$stage/modules_config.db-shm.before" ] && cp -p "$stage/modules_config.db-shm.before" "$db-shm" || rm -f "$db-shm"
echo "Restored LSPosed DB and persist.pixelxpert.disable_hooks=1 from $stage"
EOF
chmod 0755 "$stage/rollback.sh"

{
  echo "timestamp=$ts"
  echo "disable_hooks_before=$(getprop persist.pixelxpert.disable_hooks)"
  echo "unsafe_scopes_before=$(getprop persist.pixelxpert.a17.unsafe_scopes)"
  echo "scope_before="
  "$sqlite" "$db" "select app_pkg_name from scope where module_pkg_name='$pkg' order by app_pkg_name;"
} > "$stage/state-before.txt"

"$sqlite" "$db" "delete from scope where module_pkg_name='$pkg' and app_pkg_name='android';"
"$sqlite" "$db" "insert or replace into modules_state (module_pkg_name, user_id, enabled, scope_request_blocked) values ('$pkg',0,1,0);"

setprop persist.pixelxpert.disable_hooks 0
setprop persist.pixelxpert.a17.unsafe_scopes 0

{
  echo "timestamp=$ts"
  echo "rollback=$stage/rollback.sh $stage"
  echo "disable_hooks_after=$(getprop persist.pixelxpert.disable_hooks)"
  echo "unsafe_scopes_after=$(getprop persist.pixelxpert.a17.unsafe_scopes)"
  echo "scope_after="
  "$sqlite" "$db" "select app_pkg_name from scope where module_pkg_name='$pkg' order by app_pkg_name;"
} > "$stage/state-after.txt"

cat "$stage/state-after.txt"
