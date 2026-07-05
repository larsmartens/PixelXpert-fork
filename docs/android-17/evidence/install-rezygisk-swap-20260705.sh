#!/system/bin/sh
set -eu

ZIP="/data/local/tmp/ReZygisk-v1.0.0-release.zip"
EXPECTED_SHA256="7904649b8dcaf2b060c3432df4fee302aeb1258da199d2b425335e82d49510e6"
TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/rezygisk-swap-${TS}"
ROLLBACK="${STAGE}/rollback-restore-zygisksu.sh"

echo "== install ReZygisk swap =="
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
  echo "rezygisk_existed=1" > "${STAGE}/state"
else
  echo "rezygisk_existed=0" > "${STAGE}/state"
fi

cat > "${ROLLBACK}" <<EOF
#!/system/bin/sh
set -eu
if [ "\$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi
rm -rf /data/adb/modules/rezygisk
if [ -d "${STAGE}/rezygisk.before" ]; then
  cp -a "${STAGE}/rezygisk.before" /data/adb/modules/rezygisk
fi
rm -rf /data/adb/modules/zygisksu
if [ -d "${STAGE}/zygisksu.before" ]; then
  cp -a "${STAGE}/zygisksu.before" /data/adb/modules/zygisksu
fi
echo "rollback restored zygisksu/rezygisk from ${STAGE}; reboot required"
EOF
chmod 0700 "${ROLLBACK}"

if [ -d /data/adb/modules/zygisksu ]; then
  touch /data/adb/modules/zygisksu/disable
fi

/data/adb/ksud module install "${ZIP}"

if [ ! -d /data/adb/modules/rezygisk ]; then
  echo "ReZygisk module directory was not created" >&2
  exit 1
fi

rm -f /data/adb/modules/rezygisk/disable /data/adb/modules/rezygisk/remove

echo "rollback=${ROLLBACK}"
echo "zygisk_next_disabled_marker=$(test -f /data/adb/modules/zygisksu/disable && echo yes || echo no)"
echo "rezygisk_module_prop:"
grep -E '^(id|name|version|versionCode|description|managedFeatures)=' /data/adb/modules/rezygisk/module.prop || true
echo "reboot required"
