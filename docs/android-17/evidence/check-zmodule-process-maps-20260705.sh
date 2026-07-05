#!/system/bin/sh
set -eu

echo "== zygisk module process maps =="
date
for pkg in com.google.android.gms com.google.android.gms.unstable com.android.vending gr.nikolasspyr.integritycheck; do
  pids="$(pidof "$pkg" 2>/dev/null || true)"
  echo
  echo "## ${pkg}"
  if [ -z "${pids}" ]; then
    echo "no-pid"
    continue
  fi
  for pid in ${pids}; do
    echo "pid=${pid}"
    grep -Ei 'playintegrity|pif|tricky|tee|zygisk|rezygisk|libTEESimulator|classes.dex|libzygisk' "/proc/${pid}/maps" 2>/dev/null | head -120 || true
  done
done
