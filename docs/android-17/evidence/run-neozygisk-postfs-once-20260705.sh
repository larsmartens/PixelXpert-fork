#!/system/bin/sh
set -u

echo "== run NeoZygisk post-fs-data once =="
date
cd /data/adb/modules/zygisksu || exit 1
/system/bin/sh /data/adb/modules/zygisksu/post-fs-data.sh
rc=$?
echo "postfs_rc=${rc}"
sleep 1
ps -A -o USER,PID,PPID,NAME,ARGS | grep -E 'neozygisk|zygisk|zygote' | grep -v grep || true
ls -la /data/adb/neozygisk /data/adb/neozygisk/* 2>/dev/null || true
exit "${rc}"
