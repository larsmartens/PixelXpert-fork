#!/system/bin/sh
set -u

ts="$(date +%Y%m%d-%H%M%S)"
stage="/data/adb/pixelxpert-stage/disable-qorvo-uwb-$ts"
pkg="com.qorvo.uwb.vendorservice"
mkdir -p "$stage"

{
  echo "timestamp=$ts"
  echo "package=$pkg"
  dumpsys package "$pkg" | grep -E "User 0:|enabled="
  cmd package resolve-activity "$pkg" 2>&1 || true
} > "$stage/state-before.txt"

cat > "$stage/rollback.sh" <<'EOF'
#!/system/bin/sh
set -u
pkg="com.qorvo.uwb.vendorservice"
pm enable --user 0 "$pkg"
echo "Re-enabled $pkg for user 0"
EOF
chmod 0755 "$stage/rollback.sh"

pm disable-user --user 0 "$pkg"
am force-stop "$pkg" 2>/dev/null || true

{
  echo "timestamp=$ts"
  echo "rollback=$stage/rollback.sh"
  dumpsys package "$pkg" | grep -E "User 0:|enabled="
} > "$stage/state-after.txt"

cat "$stage/state-after.txt"
