#!/system/bin/sh
set -eu

BB=/data/adb/ksu/bin/busybox
[ -x "$BB" ] || BB=busybox
TS=$(date +%Y%m%d-%H%M%S)
STAGE=/data/adb/pixelxpert-stage/hybrid-provider-only-$TS
CONFIG=/data/adb/hybrid-mount/config.toml
mkdir -p "$STAGE"

echo "== preflight =="
date
id
getprop sys.boot_completed

echo "== backups =="
mkdir -p "$STAGE/markers"
for m in hybrid_mount ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos PixelXpert; do
  [ -d "/data/adb/modules/$m" ] || continue
  mkdir -p "$STAGE/markers/$m"
  for marker in disable skip_mount a17_enable_privapp_mount; do
    if [ -e "/data/adb/modules/$m/$marker" ]; then
      touch "$STAGE/markers/$m/$marker.present"
    else
      touch "$STAGE/markers/$m/$marker.absent"
    fi
  done
done
if [ -d /data/adb/hybrid-mount ]; then
  "$BB" tar -C /data/adb -cf "$STAGE/hybrid-mount.before.tar" hybrid-mount
  sha256sum "$STAGE/hybrid-mount.before.tar"
fi
if [ -d /data/adb/modules/hybrid_mount ]; then
  "$BB" tar -C /data/adb/modules -cf "$STAGE/hybrid_mount.module.before.tar" hybrid_mount
  sha256sum "$STAGE/hybrid_mount.module.before.tar"
fi

cat > "$STAGE/rollback.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
STAGE_DIR="${1:-}"
if [ -z "$STAGE_DIR" ]; then
  for d in /data/adb/pixelxpert-stage/hybrid-provider-only-*; do STAGE_DIR="$d"; done
fi
[ -d "$STAGE_DIR" ] || { echo "missing stage"; exit 1; }
if [ -f "$STAGE_DIR/hybrid-mount.before.tar" ]; then
  rm -rf /data/adb/hybrid-mount
  /data/adb/ksu/bin/busybox tar -C /data/adb -xf "$STAGE_DIR/hybrid-mount.before.tar"
fi
for md in "$STAGE_DIR"/markers/*; do
  [ -d "$md" ] || continue
  m="${md##*/}"
  [ -d "/data/adb/modules/$m" ] || continue
  for marker in disable skip_mount a17_enable_privapp_mount; do
    if [ -e "$md/$marker.present" ]; then
      touch "/data/adb/modules/$m/$marker"
    elif [ -e "$md/$marker.absent" ]; then
      rm -f "/data/adb/modules/$m/$marker"
    fi
  done
done
echo "restored markers and hybrid config from $STAGE_DIR"
ROLLBACK
chmod 0700 "$STAGE/rollback.sh"

echo "rollback=$STAGE/rollback.sh"

echo "== provider-only marker changes =="
# Keep PixelXpert explicitly no-mount.
touch /data/adb/modules/PixelXpert/skip_mount
rm -f /data/adb/modules/PixelXpert/a17_enable_privapp_mount

# Disable all enabled modules with system trees for the provider-only test.
for m in ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos; do
  [ -d "/data/adb/modules/$m" ] || continue
  touch "/data/adb/modules/$m/disable"
  echo "disabled $m"
done

# Enable Hybrid Mount if installed.
if [ -d /data/adb/modules/hybrid_mount ]; then
  rm -f /data/adb/modules/hybrid_mount/disable
  echo "enabled hybrid_mount"
else
  echo "missing /data/adb/modules/hybrid_mount"
  exit 1
fi

mkdir -p /data/adb/hybrid-mount
cat > "$CONFIG" <<'CONFIG'
moduledir = "/data/adb/modules"
mountsource = "KSU"
overlay_mode = "ext4"
disable_umount = false
default_mode = "ignore"
daemon_startup_mode = "on-demand"

[kasumi]
enabled = false

[rules.PixelXpert]
default_mode = "ignore"

[rules.PixelXpert.paths]
"system/priv-app/PixelXpert" = "ignore"

[rules.adguardcert]
default_mode = "ignore"

[rules.ViPER4Android-RE-Fork]
default_mode = "ignore"

[rules.rclone]
default_mode = "ignore"

[rules.unlimitedphotos]
default_mode = "ignore"

[rules.magisk-tailscaled]
default_mode = "ignore"
CONFIG
chmod 0644 "$CONFIG"

echo "== resulting markers =="
for m in hybrid_mount ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos PixelXpert; do
  [ -d "/data/adb/modules/$m" ] || continue
  state=enabled
  [ -e "/data/adb/modules/$m/disable" ] && state=disabled
  skip=0
  [ -e "/data/adb/modules/$m/skip_mount" ] && skip=1
  printf '%s state=%s skip_mount=%s\n' "$m" "$state" "$skip"
done
echo "stage=$STAGE"
echo "reboot required"
