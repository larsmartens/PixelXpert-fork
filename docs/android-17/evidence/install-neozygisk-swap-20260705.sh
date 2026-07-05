#!/system/bin/sh
set -eu

ZIP="/data/local/tmp/NeoZygisk-v2.3-275-release.zip"
EXPECTED_SHA256="5c84df9f962c04855b3523a3a75022cf5e4f3ad3dfd94794ed92b43e911f3b9a"
TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/neozygisk-swap-${TS}"
ROLLBACK="${STAGE}/rollback-restore-previous-zygisk-provider.sh"

echo "== install NeoZygisk swap =="
echo "stage=${STAGE}"

if [ "$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi

if [ ! -f "${ZIP}" ]; then
  echo "missing ${ZIP}" >&2
  exit 1
fi

actual="$(sha256sum "${ZIP}" | awk '{print $1}')"
echo "zip_sha256=${actual}"
if [ "${actual}" != "${EXPECTED_SHA256}" ]; then
  echo "zip hash mismatch" >&2
  exit 1
fi

mkdir -p "${STAGE}"
if [ -d /data/adb/modules/zygisksu ]; then
  cp -a /data/adb/modules/zygisksu "${STAGE}/zygisksu.before"
fi
if [ -d /data/adb/modules/rezygisk ]; then
  cp -a /data/adb/modules/rezygisk "${STAGE}/rezygisk.before"
fi

cat > "${ROLLBACK}" <<EOF
#!/system/bin/sh
set -eu
if [ "\$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi
rm -rf /data/adb/modules/zygisksu
if [ -d "${STAGE}/zygisksu.before" ]; then
  cp -a "${STAGE}/zygisksu.before" /data/adb/modules/zygisksu
fi
rm -rf /data/adb/modules/rezygisk
if [ -d "${STAGE}/rezygisk.before" ]; then
  cp -a "${STAGE}/rezygisk.before" /data/adb/modules/rezygisk
fi
echo "rollback restored previous zygisk provider state from ${STAGE}; reboot required"
EOF
chmod 0700 "${ROLLBACK}"

if [ -d /data/adb/modules/rezygisk ]; then
  touch /data/adb/modules/rezygisk/disable
fi

/data/adb/ksud module install "${ZIP}"

if ! grep -q '^name=NeoZygisk$' /data/adb/modules/zygisksu/module.prop; then
  echo "NeoZygisk did not replace zygisksu module" >&2
  exit 1
fi

rm -f /data/adb/modules/zygisksu/disable /data/adb/modules/zygisksu/remove

echo "rollback=${ROLLBACK}"
echo "provider_module:"
grep -E '^(id|name|version|versionCode|description|managedFeatures)=' /data/adb/modules/zygisksu/module.prop || true
echo "rezygisk_disabled_marker=$(test -f /data/adb/modules/rezygisk/disable && echo yes || echo no)"
echo "reboot required"
