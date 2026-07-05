#!/system/bin/sh
set -eu

ZIP="/data/local/tmp/Zygisk-Next-1.4.2-789-119aaa0-release.zip"
EXPECTED_SHA256="44f17aacfc3e40747811445a8f3f627aba195115de2f9bcf2e6ed909a993fbab"
TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/zygisknext-normal-${TS}"
ROLLBACK="${STAGE}/rollback-restore-zygisk-provider.sh"

echo "== install Zygisk Next through ksud =="
echo "stage=${STAGE}"

if [ "$(id -u)" != "0" ]; then
  echo "must run as root" >&2
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

/data/adb/ksud module install "${ZIP}"

if ! grep -q '^name=Zygisk Next$' /data/adb/modules/zygisksu/module.prop; then
  echo "Zygisk Next was not installed as zygisksu" >&2
  exit 1
fi

touch /data/adb/modules/zygisksu/disable
if [ -d /data/adb/modules/rezygisk ]; then
  touch /data/adb/modules/rezygisk/disable
fi

echo "rollback=${ROLLBACK}"
echo "provider_module:"
grep -E '^(id|name|version|versionCode|description|managedFeatures)=' /data/adb/modules/zygisksu/module.prop || true
echo "zygisksu_disabled_marker=$(test -f /data/adb/modules/zygisksu/disable && echo yes || echo no)"
echo "rezygisk_disabled_marker=$(test -f /data/adb/modules/rezygisk/disable && echo yes || echo no)"
echo "reboot required before activation test"
