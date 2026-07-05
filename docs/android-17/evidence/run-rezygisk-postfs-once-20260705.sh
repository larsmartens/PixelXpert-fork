#!/system/bin/sh
set -u

echo "== run ReZygisk post-fs-data once =="
date
cd /data/adb/modules/rezygisk || exit 1
/system/bin/sh /data/adb/modules/rezygisk/post-fs-data.sh
rc=$?
echo "postfs_rc=${rc}"
sleep 1
ps -A -o USER,PID,PPID,NAME,ARGS | grep -E 'rezygisk|zygisk|zygote' | grep -v grep || true
logcat -d -t 200 | grep -Ei 'rezygisk|zygisk|zygiskd|ptrace' | tail -100 || true
exit "${rc}"
