#!/system/bin/sh
set -u

ts="$(date +%Y%m%d-%H%M%S)"
stage="/data/adb/pixelxpert-stage/safe-module-baseline-$ts"
mods="/data/adb/modules"
mkdir -p "$stage"

log="$stage/state-before.txt"
{
  echo "timestamp=$ts"
  echo "boot_completed=$(getprop sys.boot_completed)"
  echo "bootanim=$(getprop init.svc.bootanim)"
  echo "boot_reason=$(getprop sys.boot.reason)"
  echo
  for m in PixelXpert hybrid_mount ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos zygisk_thanox; do
    d="$mods/$m"
    [ -d "$d" ] || continue
    state=enabled
    [ -e "$d/disable" ] && state=disabled
    skip=0
    [ -e "$d/skip_mount" ] && skip=1
    priv=0
    [ -e "$d/a17_enable_privapp_mount" ] && priv=1
    echo "$m state=$state skip_mount=$skip a17_enable_privapp_mount=$priv"
    find "$d" -maxdepth 2 -type f \( -name module.prop -o -name disable -o -name skip_mount -o -name a17_enable_privapp_mount \) -exec ls -lZ {} \; 2>/dev/null
    echo
  done
} > "$log"

cat > "$stage/rollback.sh" <<'EOF'
#!/system/bin/sh
set -u
src="${1:-}"
mods="/data/adb/modules"
[ -n "$src" ] || {
  echo "usage: rollback.sh /data/adb/pixelxpert-stage/safe-module-baseline-..."
  exit 2
}
restore_marker() {
  module="$1"
  marker="$2"
  file="$mods/$module/$marker"
  recorded="$src/markers/$module.$marker"
  [ -d "$mods/$module" ] || return 0
  if [ -e "$recorded" ]; then
    : > "$file"
    chmod 0644 "$file"
  else
    rm -f "$file"
  fi
}
for module in PixelXpert hybrid_mount ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos zygisk_thanox; do
  for marker in disable skip_mount a17_enable_privapp_mount; do
    restore_marker "$module" "$marker"
  done
done
echo "Restored module markers from $src"
EOF
chmod 0755 "$stage/rollback.sh"

mkdir -p "$stage/markers"
for m in PixelXpert hybrid_mount ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos zygisk_thanox; do
  for marker in disable skip_mount a17_enable_privapp_mount; do
    [ -e "$mods/$m/$marker" ] && : > "$stage/markers/$m.$marker"
  done
done

# Keep PixelXpert installed and LSPosed-enabled, but prevent priv-app/package-manager mounting.
if [ -d "$mods/PixelXpert" ]; then
  : > "$mods/PixelXpert/skip_mount"
  rm -f "$mods/PixelXpert/a17_enable_privapp_mount"
  rm -f "$mods/PixelXpert/disable"
fi

# Hybrid Mount remains disabled until a per-module boot-safe configuration is proven.
[ -d "$mods/hybrid_mount" ] && : > "$mods/hybrid_mount/disable"

# These modules were enabled but their expected system-tree targets were missing in baseline.
# Disable them for the recovery boot so they cannot participate in early mount/package scans.
for m in ViPER4Android-RE-Fork rclone unlimitedphotos; do
  [ -d "$mods/$m" ] && : > "$mods/$m/disable"
done

# AdGuard cert was validated independently and tailscaled does not populate a system tree here.
# Leave both unchanged for this first recovery. They can be disabled in the next stage if needed.

{
  echo "timestamp=$ts"
  echo "rollback=$stage/rollback.sh $stage"
  echo
  for m in PixelXpert hybrid_mount ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos zygisk_thanox; do
    d="$mods/$m"
    [ -d "$d" ] || continue
    state=enabled
    [ -e "$d/disable" ] && state=disabled
    skip=0
    [ -e "$d/skip_mount" ] && skip=1
    priv=0
    [ -e "$d/a17_enable_privapp_mount" ] && priv=1
    echo "$m state=$state skip_mount=$skip a17_enable_privapp_mount=$priv"
  done
} > "$stage/state-after.txt"

cat "$stage/state-after.txt"
