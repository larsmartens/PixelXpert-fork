#!/system/bin/sh
set -eu

SELECTED="${1:-}"
if [ -z "$SELECTED" ]; then
  echo "usage: $0 <module-id>"
  exit 2
fi

BB=/data/adb/ksu/bin/busybox
[ -x "$BB" ] || BB=busybox
TS=$(date +%Y%m%d-%H%M%S)
STAGE=/data/adb/pixelxpert-stage/hybrid-single-${SELECTED}-$TS
CONFIG=/data/adb/hybrid-mount/config.toml
SYSTEM_MODULES="ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos"
mkdir -p "$STAGE/markers"

echo "== preflight =="
date
id
getprop sys.boot_completed
[ -d /data/adb/modules/hybrid_mount ] || { echo "hybrid_mount missing"; exit 1; }
[ -d "/data/adb/modules/$SELECTED" ] || { echo "selected module missing: $SELECTED"; exit 1; }

echo "== backups =="
for m in hybrid_mount PixelXpert $SYSTEM_MODULES; do
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

cat > "$STAGE/rollback-provider-only.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
CONFIG=/data/adb/hybrid-mount/config.toml
for m in ViPER4Android-RE-Fork adguardcert magisk-tailscaled rclone unlimitedphotos; do
  [ -d "/data/adb/modules/$m" ] && touch "/data/adb/modules/$m/disable"
done
[ -d /data/adb/modules/hybrid_mount ] && rm -f /data/adb/modules/hybrid_mount/disable
[ -d /data/adb/modules/PixelXpert ] && touch /data/adb/modules/PixelXpert/skip_mount
[ -d /data/adb/modules/PixelXpert ] && rm -f /data/adb/modules/PixelXpert/a17_enable_privapp_mount
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
echo "hybrid provider-only rollback applied"
ROLLBACK
chmod 0700 "$STAGE/rollback-provider-only.sh"
echo "rollback_provider_only=$STAGE/rollback-provider-only.sh"

echo "== marker changes =="
touch /data/adb/modules/PixelXpert/skip_mount
rm -f /data/adb/modules/PixelXpert/a17_enable_privapp_mount
rm -f /data/adb/modules/hybrid_mount/disable
for m in $SYSTEM_MODULES; do
  [ -d "/data/adb/modules/$m" ] || continue
  if [ "$m" = "$SELECTED" ]; then
    rm -f "/data/adb/modules/$m/disable"
    echo "enabled $m"
  else
    touch "/data/adb/modules/$m/disable"
    echo "disabled $m"
  fi
done

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

case "$SELECTED" in
  adguardcert)
    cat >> "$CONFIG" <<'CONFIG'

[rules.adguardcert.paths]
"system/etc/security/cacerts" = "magic"
"apex/com.android.conscrypt/cacerts" = "magic"
CONFIG
    ;;
  ViPER4Android-RE-Fork)
    sed -i 's/\[rules.ViPER4Android-RE-Fork\]\ndefault_mode = "ignore"/[rules.ViPER4Android-RE-Fork]\ndefault_mode = "overlay"/' "$CONFIG" 2>/dev/null || true
    ;;
  rclone)
    sed -i 's/\[rules.rclone\]\ndefault_mode = "ignore"/[rules.rclone]\ndefault_mode = "overlay"/' "$CONFIG" 2>/dev/null || true
    ;;
  unlimitedphotos)
    sed -i 's/\[rules.unlimitedphotos\]\ndefault_mode = "ignore"/[rules.unlimitedphotos]\ndefault_mode = "overlay"/' "$CONFIG" 2>/dev/null || true
    ;;
  magisk-tailscaled)
    sed -i 's/\[rules.magisk-tailscaled\]\ndefault_mode = "ignore"/[rules.magisk-tailscaled]\ndefault_mode = "overlay"/' "$CONFIG" 2>/dev/null || true
    ;;
esac

# Android toybox sed does not handle escaped newlines consistently. Enforce selected
# overlay rules with awk when needed.
if [ "$SELECTED" != "adguardcert" ]; then
  awk -v selected="$SELECTED" '
    $0 == "[rules." selected "]" { print; getline; print "default_mode = \"overlay\""; next }
    { print }
  ' "$CONFIG" > "$CONFIG.tmp"
  mv -f "$CONFIG.tmp" "$CONFIG"
fi
chmod 0644 "$CONFIG"

echo "== resulting markers =="
for m in hybrid_mount PixelXpert $SYSTEM_MODULES; do
  [ -d "/data/adb/modules/$m" ] || continue
  state=enabled
  [ -e "/data/adb/modules/$m/disable" ] && state=disabled
  skip=0
  [ -e "/data/adb/modules/$m/skip_mount" ] && skip=1
  printf '%s state=%s skip_mount=%s\n' "$m" "$state" "$skip"
done
echo "stage=$STAGE"
echo "selected=$SELECTED"
echo "reboot required"
