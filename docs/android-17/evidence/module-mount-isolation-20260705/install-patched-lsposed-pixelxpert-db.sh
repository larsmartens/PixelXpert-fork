#!/system/bin/sh
set -u

ts="$(date +%Y%m%d-%H%M%S)"
stage="/data/adb/pixelxpert-stage/lsposed-pixelxpert-db-$ts"
src="/data/local/tmp/modules_config.pixelxpert-patched.db"
dst="/data/adb/lspd/config/modules_config.db"
mkdir -p "$stage"

[ -f "$src" ] || { echo "missing patched db: $src"; exit 1; }

cp -p "$dst" "$stage/modules_config.db.before"
[ -f "$dst-wal" ] && cp -p "$dst-wal" "$stage/modules_config.db-wal.before"
[ -f "$dst-shm" ] && cp -p "$dst-shm" "$stage/modules_config.db-shm.before"

cat > "$stage/rollback.sh" <<'EOF'
#!/system/bin/sh
set -u
stage="${1:-}"
dst="/data/adb/lspd/config/modules_config.db"
[ -n "$stage" ] || {
  echo "usage: rollback.sh /data/adb/pixelxpert-stage/lsposed-pixelxpert-db-..."
  exit 2
}
[ -f "$stage/modules_config.db.before" ] || { echo "missing backup db"; exit 1; }
cp -p "$stage/modules_config.db.before" "$dst"
rm -f "$dst-wal" "$dst-shm"
[ -f "$stage/modules_config.db-wal.before" ] && cp -p "$stage/modules_config.db-wal.before" "$dst-wal"
[ -f "$stage/modules_config.db-shm.before" ] && cp -p "$stage/modules_config.db-shm.before" "$dst-shm"
echo "Rolled back LSPosed modules_config from $stage"
EOF
chmod 0755 "$stage/rollback.sh"

{
  echo "timestamp=$ts"
  echo "rollback=$stage/rollback.sh $stage"
  ls -lZ "$dst" "$dst-wal" "$dst-shm" 2>/dev/null || true
  sha256sum "$dst" "$src" 2>/dev/null || true
} > "$stage/state-before.txt"

cp "$src" "$dst"
chmod 0600 "$dst" 2>/dev/null || true
chown root:root "$dst" 2>/dev/null || true
rm -f "$dst-wal" "$dst-shm"

{
  echo "timestamp=$ts"
  echo "rollback=$stage/rollback.sh $stage"
  ls -lZ "$dst" "$dst-wal" "$dst-shm" 2>/dev/null || true
  sha256sum "$dst" 2>/dev/null || true
} > "$stage/state-after.txt"

cat "$stage/state-after.txt"
