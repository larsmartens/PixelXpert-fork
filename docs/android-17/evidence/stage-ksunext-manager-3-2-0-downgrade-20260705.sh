#!/system/bin/sh
set -eu

V32="/data/local/tmp/KernelSU_Next_v3.2.0_33129-release.apk"
V33="/data/local/tmp/KernelSU_Next_v3.3.0_33214-release.apk"
V32_SHA256="96c2bbbf1b973461fe82dd1ed17f89deb86a6a5a9d7c4cf079bd32091131ef57"
V33_SHA256="fd0b12385c98fe9d5f4f1257b5f184e55c74c1376637507df0718305f5d7a924"
TS="$(date +%Y%m%d-%H%M%S)"
STAGE="/data/adb/pixelxpert-stage/ksunext-manager-downgrade-${TS}"
ROLLBACK="${STAGE}/rollback-install-ksunext-manager-3-3-0.sh"

echo "== stage KSU-Next Manager 3.2.0 downgrade =="
echo "stage=${STAGE}"

if [ "$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi

for pair in "${V32}:${V32_SHA256}" "${V33}:${V33_SHA256}"; do
  file="${pair%%:*}"
  expected="${pair##*:}"
  actual="$(sha256sum "${file}" | awk '{print $1}')"
  echo "${file}_sha256=${actual}"
  if [ "${actual}" != "${expected}" ]; then
    echo "hash mismatch for ${file}" >&2
    exit 1
  fi
done

mkdir -p "${STAGE}"
dumpsys package com.rifsxd.ksunext > "${STAGE}/package.before.txt" 2>/dev/null || true

cat > "${ROLLBACK}" <<EOF
#!/system/bin/sh
set -eu
if [ "\$(id -u)" != "0" ]; then
  echo "must run as root" >&2
  exit 1
fi
pm install -r "${V33}"
dumpsys package com.rifsxd.ksunext | grep -E 'versionCode|versionName|lastUpdateTime' || true
echo "rollback installed KSU-Next Manager v3.3.0"
EOF
chmod 0700 "${ROLLBACK}"

echo "rollback=${ROLLBACK}"
echo "current_manager:"
dumpsys package com.rifsxd.ksunext | grep -E 'versionCode|versionName|lastUpdateTime' || true
