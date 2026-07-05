#!/system/bin/sh
set -eu

TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/hybridmount-metamodule-isolation-${TS}"
ROLLBACK="${STAGE}/rollback-restore-hybridmount.sh"
SRC="/data/adb/modules/hybrid_mount"
DST="${STAGE}/hybrid_mount"

echo "== isolate HybridMount metamodule =="
echo "stage=${STAGE}"

if [ "$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi

mkdir -p "${STAGE}"

cat > "${ROLLBACK}" <<EOF
#!/system/bin/sh
set -eu
if [ "\$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi
if [ -d "${DST}" ]; then
  rm -rf "${SRC}"
  mv "${DST}" "${SRC}"
fi
echo "rollback restored HybridMount metamodule from ${STAGE}; reboot recommended"
EOF
chmod 0700 "${ROLLBACK}"

if [ -d "${SRC}" ]; then
  grep -E '^(id|name|version|versionCode|description|metamodule)=' "${SRC}/module.prop" > "${STAGE}/module.before.txt" 2>/dev/null || true
  ls -la "${SRC}/disable" "${SRC}/remove" > "${STAGE}/markers.before.txt" 2>/dev/null || true
  mv "${SRC}" "${DST}"
fi

echo "rollback=${ROLLBACK}"
echo "hybrid_mount_present=$(test -d "${SRC}" && echo yes || echo no)"
echo "hybrid_mount_isolated=$(test -d "${DST}" && echo yes || echo no)"
/data/adb/ksud module list >/dev/null
echo "module_list=ok"
