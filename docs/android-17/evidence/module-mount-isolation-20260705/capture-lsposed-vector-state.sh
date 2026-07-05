#!/system/bin/sh
set -u

echo "== modules =="
for m in lsposed zygisk_lsposed zygisk_lsposed_mod lspatch zygisksu zygisk_next ZygiskNext neozygisk NeoZygisk; do
  for d in "/data/adb/modules/$m" "/data/adb/modules_update/$m"; do
    [ -d "$d" ] || continue
    state=enabled
    [ -e "$d/disable" ] && state=disabled
    echo "$d state=$state"
    [ -f "$d/module.prop" ] && cat "$d/module.prop"
    echo
  done
done

echo "== matching paths =="
find /data/adb -maxdepth 5 -type f -o -type d 2>/dev/null | grep -Ei 'lspd|lsposed|vector|zygisknext|neozygisk' | head -300

echo "== processes =="
ps -A -o PID,USER,NAME,ARGS 2>/dev/null | grep -Ei 'lspd|lsposed|vector|zygisk|zygote' | grep -v grep

echo "== packages =="
pm list packages | grep -Ei 'lsposed|lspatch|pixelxpert|zygisk|kernel|ksu' || true
