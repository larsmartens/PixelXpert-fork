#!/system/bin/sh
set -u

echo "## context"
date
id
echo "boot_completed=$(getprop sys.boot_completed)"
echo "bootanim=$(getprop init.svc.bootanim)"

echo
echo "## current modules"
for prop in /data/adb/modules/*/module.prop; do
  [ -f "$prop" ] || continue
  dir="$(dirname "$prop")"
  id="$(basename "$dir")"
  state=enabled
  [ -f "$dir/disable" ] && state=disabled
  remove=no
  [ -f "$dir/remove" ] && remove=yes
  skip_mount=no
  [ -f "$dir/skip_mount" ] && skip_mount=yes
  echo "### $id"
  echo "state=$state remove=$remove skip_mount=$skip_mount"
  ls -ldZ "$dir" 2>/dev/null || true
  grep -E '^(id|name|version|versionCode|author|description|updateJson)=' "$prop" 2>/dev/null || true
done

echo
echo "## modules_update"
for prop in /data/adb/modules_update/*/module.prop; do
  [ -f "$prop" ] || continue
  dir="$(dirname "$prop")"
  id="$(basename "$dir")"
  echo "### $id"
  ls -ldZ "$dir" 2>/dev/null || true
  grep -E '^(id|name|version|versionCode|author|description|updateJson)=' "$prop" 2>/dev/null || true
done

echo
echo "## pixelxpert-stage rollback tree"
find /data/adb/pixelxpert-stage -maxdepth 3 -type f \
  \( -name '*rollback*' -o -name 'module.prop' -o -name '*modules_config*' -o -name '*state*' -o -name '*.txt' -o -name '*.md' \) \
  -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n' 2>/dev/null | sort || true

echo
echo "## module disable marker mtimes"
for marker in /data/adb/modules/*/disable /data/adb/modules/*/remove /data/adb/modules/*/skip_mount; do
  [ -e "$marker" ] || continue
  ls -lZ "$marker" 2>/dev/null || true
done

echo
echo "## possible manager/history files"
find /data/adb /data/user_de/0 /data/data -maxdepth 6 \
  \( -iname '*mmrl*' -o -iname '*kernelsu*' -o -iname '*ksunext*' -o -iname '*module*' -o -iname '*history*' \) \
  -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n' 2>/dev/null | sort | tail -n 300 || true
