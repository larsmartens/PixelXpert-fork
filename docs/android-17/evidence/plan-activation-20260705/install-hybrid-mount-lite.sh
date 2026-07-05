#!/system/bin/sh
set -eu

BB=/data/adb/ksu/bin/busybox
[ -x "$BB" ] || BB=busybox

ZIP=/data/local/tmp/Hybrid-Mount-Lite-4.2.0-1815.zip
STAGE=/data/adb/pixelxpert-stage/hybrid-mount-lite-20260705
CONFIG=/data/adb/hybrid-mount/config.toml
MOD=/data/adb/modules/hybrid_mount
MODUPD=/data/adb/modules_update/hybrid_mount
KSUD=/data/adb/ksu/bin/ksud
[ -x "$KSUD" ] || KSUD=ksud

mkdir -p "$STAGE"

echo "== preflight =="
date
id
getprop sys.boot_completed
if [ ! -f "$ZIP" ]; then
  echo "Missing $ZIP"
  exit 1
fi
sha256sum "$ZIP"

echo "== backup =="
if [ -d /data/adb/hybrid-mount ]; then
  "$BB" tar -C /data/adb -cf "$STAGE/hybrid-mount-before.tar" hybrid-mount
  sha256sum "$STAGE/hybrid-mount-before.tar"
fi
if [ -d "$MOD" ]; then
  "$BB" tar -C /data/adb/modules -cf "$STAGE/hybrid_mount-module-before.tar" hybrid_mount
  sha256sum "$STAGE/hybrid_mount-module-before.tar"
fi
if [ -d "$MODUPD" ]; then
  "$BB" tar -C /data/adb/modules_update -cf "$STAGE/hybrid_mount-module-update-before.tar" hybrid_mount
  sha256sum "$STAGE/hybrid_mount-module-update-before.tar"
fi

cat > "$STAGE/rollback-disable-hybrid-mount.sh" <<'ROLLBACK'
#!/system/bin/sh
set -eu
STAGE=/data/adb/pixelxpert-stage/hybrid-mount-lite-20260705
if [ -d /data/adb/modules/hybrid_mount ]; then
  touch /data/adb/modules/hybrid_mount/disable
fi
if [ -d /data/adb/modules_update/hybrid_mount ]; then
  touch /data/adb/modules_update/hybrid_mount/disable
fi
if [ -f "$STAGE/hybrid-mount-before.tar" ]; then
  rm -rf /data/adb/hybrid-mount
  /data/adb/ksu/bin/busybox tar -C /data/adb -xf "$STAGE/hybrid-mount-before.tar"
fi
echo "Hybrid Mount disabled and previous config restored if backup existed"
ROLLBACK
chmod 0700 "$STAGE/rollback-disable-hybrid-mount.sh"
echo "rollback=$STAGE/rollback-disable-hybrid-mount.sh"

echo "== install =="
"$KSUD" module install "$ZIP"

echo "== configure =="
mkdir -p /data/adb/hybrid-mount
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<'CONFIG'
moduledir = "/data/adb/modules"
mountsource = "KSU"
overlay_mode = "ext4"
disable_umount = false
default_mode = "overlay"
daemon_startup_mode = "on-demand"
CONFIG
fi

if ! "$BB" grep -q '^\[rules.adguardcert\]' "$CONFIG"; then
  cat >> "$CONFIG" <<'CONFIG'

[rules.adguardcert]
default_mode = "magic"

[rules.adguardcert.paths]
"system/etc/security/cacerts" = "magic"
"apex/com.android.conscrypt/cacerts" = "magic"
CONFIG
else
  if ! "$BB" grep -q '"system/etc/security/cacerts"[[:space:]]*=[[:space:]]*"magic"' "$CONFIG"; then
    "$BB" awk '
      BEGIN { inserted=0 }
      { print }
      $0 == "[rules.adguardcert.paths]" && inserted == 0 {
        print "\"system/etc/security/cacerts\" = \"magic\""
        print "\"apex/com.android.conscrypt/cacerts\" = \"magic\""
        inserted=1
      }
      END {
        if (inserted == 0) {
          print ""
          print "[rules.adguardcert.paths]"
          print "\"system/etc/security/cacerts\" = \"magic\""
          print "\"apex/com.android.conscrypt/cacerts\" = \"magic\""
        }
      }
    ' "$CONFIG" > "$CONFIG.tmp"
    mv -f "$CONFIG.tmp" "$CONFIG"
  fi
fi

if ! "$BB" grep -q '^\[rules.PixelXpert\]' "$CONFIG"; then
  cat >> "$CONFIG" <<'CONFIG'

[rules.PixelXpert]
default_mode = "overlay"

[rules.PixelXpert.paths]
"system/priv-app/PixelXpert" = "ignore"
CONFIG
elif ! "$BB" grep -q '"system/priv-app/PixelXpert"[[:space:]]*=[[:space:]]*"ignore"' "$CONFIG"; then
  "$BB" awk '
    BEGIN { inserted=0 }
    { print }
    $0 == "[rules.PixelXpert.paths]" && inserted == 0 {
      print "\"system/priv-app/PixelXpert\" = \"ignore\""
      inserted=1
    }
    END {
      if (inserted == 0) {
        print ""
        print "[rules.PixelXpert.paths]"
        print "\"system/priv-app/PixelXpert\" = \"ignore\""
      }
    }
  ' "$CONFIG" > "$CONFIG.tmp"
  mv -f "$CONFIG.tmp" "$CONFIG"
fi

chmod 0644 "$CONFIG"

echo "== installed state =="
/data/adb/ksu/bin/ksud module list 2>/dev/null | "$BB" grep -Ei '"id":"([^"]*(hybrid|overlay|magic|mountify|susfs)[^"]*)"' || true
[ -d "$MOD" ] && "$BB" find "$MOD" -maxdepth 2 -print | "$BB" head -120 || true
echo "-- config --"
"$BB" sed -n '1,220p' "$CONFIG"
echo "Hybrid Mount Lite installed/configured; reboot required for boot-time mount orchestration"
