#!/system/bin/sh
set -eu

SOURCE="/data/local/tmp/ksud-v3.2.0"
EXPECTED_SHA256="bb231b0f77d6ee78a4362ff751b3cc54c934293a4b0acde177afa59c4a64da00"
TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/ksud-align-3-2-0-${TS}"
ROLLBACK="${STAGE}/rollback-restore-ksud.sh"

echo "== align live ksud to 3.2.0 =="
echo "stage=${STAGE}"

if [ "$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi

actual="$(sha256sum "${SOURCE}" | awk '{print $1}')"
echo "source_sha256=${actual}"
if [ "${actual}" != "${EXPECTED_SHA256}" ]; then
  echo "source ksud hash mismatch" >&2
  exit 1
fi

mkdir -p "${STAGE}"
cp -a /data/adb/ksud "${STAGE}/ksud.before"
sha256sum "${STAGE}/ksud.before" > "${STAGE}/ksud.before.sha256"

cat > "${ROLLBACK}" <<EOF
#!/system/bin/sh
set -eu
if [ "\$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi
cp -f "${STAGE}/ksud.before" /data/adb/ksud
chown 0:0 /data/adb/ksud
chmod 0755 /data/adb/ksud
chcon u:object_r:ksu_file:s0 /data/adb/ksud 2>/dev/null || true
/data/adb/ksud -V 2>&1 || true
echo "rollback restored ksud from ${STAGE}"
EOF
chmod 0700 "${ROLLBACK}"

cp -f "${SOURCE}" /data/adb/ksud.new
chown 0:0 /data/adb/ksud.new
chmod 0755 /data/adb/ksud.new
chcon u:object_r:ksu_file:s0 /data/adb/ksud.new 2>/dev/null || true
mv -f /data/adb/ksud.new /data/adb/ksud

echo "rollback=${ROLLBACK}"
echo "before_sha256=$(cat "${STAGE}/ksud.before.sha256" | awk '{print $1}')"
echo "after_sha256=$(sha256sum /data/adb/ksud | awk '{print $1}')"
/data/adb/ksud -V
/data/adb/ksud module list >/dev/null
echo "module_list=ok"
/data/adb/ksud module install --help >/dev/null
echo "module_install_help=ok"
