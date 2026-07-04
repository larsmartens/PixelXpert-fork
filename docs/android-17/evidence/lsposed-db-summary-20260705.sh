#!/system/bin/sh
set -u

echo "## context"
date
id

sqlite=""
for s in /data/adb/modules/PixelXpert/sqlite3 /data/adb/modules/zygisk_lsposed/sqlite3 /data/adb/ksu/bin/sqlite3 /system/bin/sqlite3; do
  if [ -x "$s" ]; then
    sqlite="$s"
    break
  fi
done
echo "sqlite=$sqlite"

echo
echo "## candidates"
for d in /data/adb/lspd /data/adb/modules/zygisk_lsposed /data/adb/modules/*lsposed*; do
  [ -e "$d" ] || continue
  echo "### $d"
  find "$d" -maxdepth 5 -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.conf' -o -name '*.json' \) -print 2>/dev/null
done

echo
echo "## db summaries"
if [ -z "$sqlite" ]; then
  echo "sqlite unavailable"
  exit 0
fi

for db in $(find /data/adb/lspd /data/adb/modules/zygisk_lsposed -maxdepth 5 -type f -name '*.db' 2>/dev/null); do
  echo
  echo "### $db"
  ls -lZ "$db" 2>/dev/null
  sha256sum "$db" 2>/dev/null
  echo "-- tables"
  "$sqlite" "$db" "select name from sqlite_master where type='table' order by 1;" 2>&1
  for t in modules scope app; do
    echo "-- table $t"
    "$sqlite" "$db" "select * from $t;" 2>&1
  done
done
