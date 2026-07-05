#!/system/bin/sh
set -eu

TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/zygisknext-enable-${TS}"
ROLLBACK="${STAGE}/rollback-disable-zygisknext.sh"

echo "== enable Zygisk Next =="
echo "stage=${STAGE}"

if [ "$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi

mkdir -p "${STAGE}"
grep -E '^(id|name|version|versionCode|description)=' /data/adb/modules/zygisksu/module.prop > "${STAGE}/zygisksu.before.txt" 2>/dev/null || true

cat > "${ROLLBACK}" <<EOF
#!/system/bin/sh
set -eu
if [ "\$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi
touch /data/adb/modules/zygisksu/disable
echo "rollback disabled Zygisk Next from ${STAGE}; reboot required"
EOF
chmod 0700 "${ROLLBACK}"

if ! grep -q '^name=Zygisk Next$' /data/adb/modules/zygisksu/module.prop; then
  echo "zygisksu is not Zygisk Next" >&2
  exit 1
fi

/data/adb/ksud module enable zygisksu
touch /data/adb/modules/rezygisk/disable 2>/dev/null || true
touch /data/adb/modules/zygisk_lsposed/disable 2>/dev/null || true
touch /data/adb/modules/PixelXpert/disable 2>/dev/null || true
touch /data/adb/modules/zygisk_nohello/disable 2>/dev/null || true

echo "rollback=${ROLLBACK}"
echo "zygisksu_disabled_marker=$(test -f /data/adb/modules/zygisksu/disable && echo yes || echo no)"
echo "rezygisk_disabled_marker=$(test -f /data/adb/modules/rezygisk/disable && echo yes || echo no)"
echo "lsposed_disabled_marker=$(test -f /data/adb/modules/zygisk_lsposed/disable && echo yes || echo no)"
echo "pixelxpert_disabled_marker=$(test -f /data/adb/modules/PixelXpert/disable && echo yes || echo no)"
echo "reboot required"
