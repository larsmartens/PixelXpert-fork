#!/system/bin/sh
set -eu

ZIP="/data/local/tmp/NeoZygisk-v2.3-275-release.zip"
EXPECTED_SHA256="5c84df9f962c04855b3523a3a75022cf5e4f3ad3dfd94794ed92b43e911f3b9a"
TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/neozygisk-manual-${TS}"
MODPATH="/data/adb/modules/zygisksu"
ROLLBACK="${STAGE}/rollback-restore-previous-zygisksu-rezygisk.sh"

echo "== manual NeoZygisk stage =="
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

if [ -d /data/adb/modules/rezygisk ]; then
  touch /data/adb/modules/rezygisk/disable
fi

rm -rf "${MODPATH}"
mkdir -p "${MODPATH}/bin" "${MODPATH}/lib" "${MODPATH}/lib64"

unzip -o "${ZIP}" action.sh module.prop post-fs-data.sh service.sh uninstall.sh sepolicy.rule -d "${MODPATH}" >/dev/null
unzip -p "${ZIP}" zygisk-ctl.sh > "${MODPATH}/bin/zygisk-ctl"
unzip -oj "${ZIP}" 'bin/arm64-v8a/zygiskd' -d "${MODPATH}/bin" >/dev/null
mv "${MODPATH}/bin/zygiskd" "${MODPATH}/bin/zygiskd64"
unzip -oj "${ZIP}" 'lib/arm64-v8a/libzygisk.so' -d "${MODPATH}/lib64" >/dev/null
unzip -oj "${ZIP}" 'lib/arm64-v8a/libzygisk_ptrace.so' -d "${MODPATH}/bin" >/dev/null
mv "${MODPATH}/bin/libzygisk_ptrace.so" "${MODPATH}/bin/zygisk-ptrace64"

chmod 0755 "${MODPATH}" "${MODPATH}/bin" "${MODPATH}/lib" "${MODPATH}/lib64"
find "${MODPATH}" -type d -exec chmod 0755 {} +
find "${MODPATH}" -type f -exec chmod 0644 {} +
chmod 0755 "${MODPATH}/action.sh" "${MODPATH}/post-fs-data.sh" "${MODPATH}/service.sh" "${MODPATH}/uninstall.sh"
chmod 0755 "${MODPATH}/bin/zygisk-ctl" "${MODPATH}/bin/zygiskd64" "${MODPATH}/bin/zygisk-ptrace64"
chown -R 0:0 "${MODPATH}"
chcon -R u:object_r:system_file:s0 "${MODPATH}" 2>/dev/null || true
chcon -R u:object_r:system_lib_file:s0 "${MODPATH}/lib" "${MODPATH}/lib64" 2>/dev/null || true

rm -f "${MODPATH}/disable" "${MODPATH}/remove"

echo "rollback=${ROLLBACK}"
echo "provider_module:"
grep -E '^(id|name|version|versionCode|description|managedFeatures)=' "${MODPATH}/module.prop" || true
echo "rezygisk_disabled_marker=$(test -f /data/adb/modules/rezygisk/disable && echo yes || echo no)"
echo "live_hashes:"
sha256sum "${MODPATH}/bin/zygiskd64" "${MODPATH}/bin/zygisk-ptrace64" "${MODPATH}/lib64/libzygisk.so"
echo "reboot required"
