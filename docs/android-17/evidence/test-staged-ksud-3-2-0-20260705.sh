#!/system/bin/sh
set -eu

KSUD="/data/local/tmp/ksud-v3.2.0"
EXPECTED_SHA256="bb231b0f77d6ee78a4362ff751b3cc54c934293a4b0acde177afa59c4a64da00"

echo "== staged ksud 3.2.0 test =="
date

if [ "$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi

actual="$(sha256sum "${KSUD}" | awk '{print $1}')"
echo "staged_sha256=${actual}"
if [ "${actual}" != "${EXPECTED_SHA256}" ]; then
  echo "staged ksud hash mismatch" >&2
  exit 1
fi

chmod 0755 "${KSUD}"
chcon u:object_r:ksu_file:s0 "${KSUD}" 2>/dev/null || true

echo "live_ksud:"
/data/adb/ksud -V 2>&1 || true
sha256sum /data/adb/ksud 2>/dev/null || true
ls -lZ /data/adb/ksud 2>/dev/null || true

echo "staged_ksud:"
"${KSUD}" -V
"${KSUD}" module list >/dev/null
echo "staged_module_list=ok"
"${KSUD}" module install --help >/dev/null
echo "staged_module_install_help=ok"
"${KSUD}" boot-info 2>&1 || true
