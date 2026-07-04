#!/system/bin/sh
set -u

section() {
  echo
  echo "## $1"
}

section "time-and-boot"
date
uptime
echo "root=$(id 2>/dev/null)"
for p in \
  ro.build.version.sdk \
  ro.build.fingerprint \
  ro.product.device \
  ro.bootmode \
  sys.boot_completed \
  init.svc.bootanim; do
  echo "$p=$(getprop "$p")"
done

section "modules"
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  name="${d##*/}"
  echo
  echo "### $name"
  if [ -f "$d/module.prop" ]; then
    sed -n '1,80p' "$d/module.prop" 2>/dev/null
    sha256sum "$d/module.prop" 2>/dev/null
  else
    echo "module.prop=missing"
  fi
  for marker in disable remove skip_mount mount_error update; do
    if [ -e "$d/$marker" ]; then
      ls -lZ "$d/$marker" 2>/dev/null
    fi
  done
done

section "pixelxpert-files"
for f in \
  /data/adb/modules/PixelXpert/disable \
  /data/adb/modules/PixelXpert/skip_mount \
  /data/adb/modules/PixelXpert/mount_error \
  /data/adb/modules/PixelXpert/customize.sh \
  /data/adb/modules/PixelXpert/service.sh \
  /data/adb/modules/PixelXpert/system/priv-app/PixelXpert/PixelXpert.apk; do
  if [ -e "$f" ]; then
    ls -lZ "$f" 2>/dev/null
    sha256sum "$f" 2>/dev/null
  else
    echo "missing $f"
  fi
done

section "dropbox-system-server-files"
found=0
for pattern in \
  /data/system/dropbox/system_server_crash* \
  /data/system/dropbox/system_server_watchdog* \
  /data/system/dropbox/system_server_pre_watchdog* \
  /data/system/dropbox/system_server_anr*; do
  for f in $pattern; do
    [ -e "$f" ] || continue
    found=1
    ls -lZ "$f" 2>/dev/null
  done
done
[ "$found" -eq 1 ] || echo "none"

section "dropbox-system-server-latest-heads"
for f in $(ls -1t /data/system/dropbox/system_server_* 2>/dev/null | head -n 8); do
  [ -f "$f" ] || continue
  echo
  echo "### $f"
  case "$f" in
    *.gz) gzip -cd "$f" 2>/dev/null | sed -n '1,120p' ;;
    *) sed -n '1,120p' "$f" 2>/dev/null ;;
  esac
done

section "tombstones"
ls -lZ /data/tombstones 2>/dev/null | tail -n 40

section "lsposed-config-candidates"
for d in /data/adb/lspd /data/adb/modules/zygisk_lsposed /data/adb/modules/*lsposed*; do
  [ -e "$d" ] || continue
  echo
  echo "### $d"
  find "$d" -maxdepth 4 -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.conf' -o -name '*.json' \) -print 2>/dev/null
done

section "lsposed-config-db-summary"
sqlite=""
for s in /data/adb/modules/PixelXpert/sqlite3 /data/adb/modules/zygisk_lsposed/sqlite3 /data/adb/ksu/bin/sqlite3 /system/bin/sqlite3; do
  if [ -x "$s" ]; then
    sqlite="$s"
    break
  fi
done
echo "sqlite=$sqlite"
for db in \
  /data/adb/lspd/config/modules_config.db \
  /data/adb/modules/zygisk_lsposed/config/modules_config.db; do
  [ -f "$db" ] || continue
  echo
  echo "### $db"
  ls -lZ "$db" 2>/dev/null
  sha256sum "$db" 2>/dev/null
  if [ -n "$sqlite" ]; then
    "$sqlite" "$db" ".tables" 2>/dev/null
    "$sqlite" "$db" "select name from sqlite_master where type='table' order by 1;" 2>/dev/null
    "$sqlite" "$db" "select * from modules;" 2>/dev/null
    "$sqlite" "$db" "select * from scope;" 2>/dev/null
    "$sqlite" "$db" "select * from app;" 2>/dev/null
  fi
done

section "mountinfo-pixelxpert-root"
grep -E 'PixelXpert|zygisk|lspd|KernelSU|ksu|rvmm|tricky|tee|thanox' /proc/self/mountinfo 2>/dev/null | head -n 120

section "recent-system-server-logcat"
logcat -d -t 1500 2>/dev/null | grep -E 'system_server|Watchdog|pre_watchdog|ANR|l53202|LSPosed|Xposed|avc: denied' | tail -n 250
