#!/system/bin/sh
set -eu

ZIP="/data/local/tmp/ReZygisk-v1.0.0-release.zip"
EXPECTED_SHA256="7904649b8dcaf2b060c3432df4fee302aeb1258da199d2b425335e82d49510e6"
TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/rezygisk-manual-${TS}"
MODPATH="/data/adb/modules/rezygisk"
ROLLBACK="${STAGE}/rollback-remove-rezygisk-restore-zygisksu.sh"

echo "== manual ReZygisk stage =="
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

pre_swap_zygisksu="$(ls -td /data/adb/pixelxpert-stage/rezygisk-swap-*/zygisksu.before 2>/dev/null | head -1 || true)"
if [ -n "${pre_swap_zygisksu}" ] && [ -d "${pre_swap_zygisksu}" ]; then
  cp -a "${pre_swap_zygisksu}" "${STAGE}/zygisksu.restore"
else
  cp -a /data/adb/modules/zygisksu "${STAGE}/zygisksu.restore"
fi

if [ -d "${MODPATH}" ]; then
  cp -a "${MODPATH}" "${STAGE}/rezygisk.before"
fi

if [ -f /data/adb/post-fs-data.d/rezygisk.sh ]; then
  mkdir -p "${STAGE}/post-fs-data.d"
  cp -a /data/adb/post-fs-data.d/rezygisk.sh "${STAGE}/post-fs-data.d/rezygisk.sh"
fi

if [ -f /data/adb/post-mount.d/rezygisk.sh ]; then
  mkdir -p "${STAGE}/post-mount.d"
  cp -a /data/adb/post-mount.d/rezygisk.sh "${STAGE}/post-mount.d/rezygisk.sh"
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
rm -f /data/adb/post-fs-data.d/rezygisk.sh /data/adb/post-mount.d/rezygisk.sh
if [ -f "${STAGE}/post-fs-data.d/rezygisk.sh" ]; then
  mkdir -p /data/adb/post-fs-data.d
  cp -a "${STAGE}/post-fs-data.d/rezygisk.sh" /data/adb/post-fs-data.d/rezygisk.sh
fi
if [ -f "${STAGE}/post-mount.d/rezygisk.sh" ]; then
  mkdir -p /data/adb/post-mount.d
  cp -a "${STAGE}/post-mount.d/rezygisk.sh" /data/adb/post-mount.d/rezygisk.sh
fi
rm -rf /data/adb/modules/zygisksu
cp -a "${STAGE}/zygisksu.restore" /data/adb/modules/zygisksu
echo "rollback restored Zygisk Next and removed manual ReZygisk stage; reboot required"
EOF
chmod 0700 "${ROLLBACK}"

rm -rf "${MODPATH}"
mkdir -p "${MODPATH}/bin" "${MODPATH}/lib64" "${MODPATH}/webroot"

unzip -o "${ZIP}" module.prop post-fs-data.sh service.sh uninstall.sh sepolicy.rule -d "${MODPATH}" >/dev/null
cp "${MODPATH}/module.prop" "${MODPATH}/module.prop.bak"

unzip -o "${ZIP}" 'webroot/*' -x '*.sha256' -d "${MODPATH}" >/dev/null

unzip -oj "${ZIP}" 'bin/arm64-v8a/zygiskd' -d "${MODPATH}/bin" >/dev/null
mv "${MODPATH}/bin/zygiskd" "${MODPATH}/bin/zygiskd64"
unzip -oj "${ZIP}" 'lib/arm64-v8a/libzygisk.so' -d "${MODPATH}/lib64" >/dev/null
unzip -oj "${ZIP}" 'lib/arm64-v8a/libzygisk_ptrace.so' -d "${MODPATH}/bin" >/dev/null
mv "${MODPATH}/bin/libzygisk_ptrace.so" "${MODPATH}/bin/zygisk-ptrace64"
unzip -oj "${ZIP}" 'machikado.arm64' -d "${MODPATH}" >/dev/null

mkdir -p /data/adb/post-fs-data.d /data/adb/post-mount.d
unzip -p "${ZIP}" rezygisk.sh > /data/adb/post-fs-data.d/rezygisk.sh
cp /data/adb/post-fs-data.d/rezygisk.sh /data/adb/post-mount.d/rezygisk.sh

chmod 0755 "${MODPATH}" "${MODPATH}/bin" "${MODPATH}/lib64" "${MODPATH}/webroot"
find "${MODPATH}" -type d -exec chmod 0755 {} +
find "${MODPATH}" -type f -exec chmod 0644 {} +
chmod 0755 "${MODPATH}/post-fs-data.sh" "${MODPATH}/service.sh" "${MODPATH}/uninstall.sh"
chmod 0755 "${MODPATH}/bin/zygiskd64" "${MODPATH}/bin/zygisk-ptrace64"
chmod 0755 /data/adb/post-fs-data.d/rezygisk.sh /data/adb/post-mount.d/rezygisk.sh

chown -R 0:0 "${MODPATH}" /data/adb/post-fs-data.d/rezygisk.sh /data/adb/post-mount.d/rezygisk.sh
chcon -R u:object_r:system_file:s0 "${MODPATH}" /data/adb/post-fs-data.d/rezygisk.sh /data/adb/post-mount.d/rezygisk.sh 2>/dev/null || true
chcon -R u:object_r:system_lib_file:s0 "${MODPATH}/lib64" 2>/dev/null || true

touch /data/adb/modules/zygisksu/disable
rm -f "${MODPATH}/disable" "${MODPATH}/remove"

echo "rollback=${ROLLBACK}"
echo "zygisk_next_disabled_marker=$(test -f /data/adb/modules/zygisksu/disable && echo yes || echo no)"
echo "rezygisk_module_prop:"
grep -E '^(id|name|version|versionCode|description|managedFeatures)=' "${MODPATH}/module.prop" || true
echo "live_hashes:"
sha256sum "${MODPATH}/bin/zygiskd64" "${MODPATH}/bin/zygisk-ptrace64" "${MODPATH}/lib64/libzygisk.so"
echo "reboot required"
