#!/system/bin/sh
set -eu

BB=/data/adb/ksu/bin/busybox
[ -x "$BB" ] || BB=busybox
OUT=/data/local/tmp/module-mount-inventory.txt
: > "$OUT"

section() {
  echo >> "$OUT"
  echo "== $1 ==" >> "$OUT"
}

section "identity"
date >> "$OUT"
id >> "$OUT"
getprop ro.build.version.sdk >> "$OUT"
getprop ro.build.fingerprint >> "$OUT"
getprop sys.boot_completed >> "$OUT"
/data/adb/ksu/bin/ksud -V >> "$OUT" 2>/dev/null || true
uname -a >> "$OUT"

section "module matrix"
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  id="${d##*/}"
  state=enabled
  [ -e "$d/disable" ] && state=disabled
  skip=0
  [ -e "$d/skip_mount" ] && skip=1
  system=0
  [ -d "$d/system" ] && system=1
  sepolicy=0
  [ -f "$d/sepolicy.rule" ] && sepolicy=1
  scripts=""
  for s in post-fs-data.sh post-mount.sh service.sh late-load.sh action.sh customize.sh; do
    [ -f "$d/$s" ] && scripts="${scripts}${s},"
  done
  ver="$("$BB" sed -n 's/^version=//p' "$d/module.prop" 2>/dev/null | "$BB" head -1)"
  name="$("$BB" sed -n 's/^name=//p' "$d/module.prop" 2>/dev/null | "$BB" head -1)"
  printf '%s state=%s skip_mount=%s system=%s sepolicy=%s scripts=%s name=%s version=%s\n' \
    "$id" "$state" "$skip" "$system" "$sepolicy" "$scripts" "$name" "$ver" >> "$OUT"
done | "$BB" sort >> "$OUT"

section "module system trees"
for d in /data/adb/modules/*; do
  [ -d "$d/system" ] || continue
  id="${d##*/}"
  echo "-- $id --" >> "$OUT"
  find "$d/system" -maxdepth 5 -type d 2>/dev/null |
    sed "s#^$d/system#/system#" |
    sort |
    head -120 >> "$OUT" || true
  echo "file_count=$(find "$d/system" -type f 2>/dev/null | wc -l)" >> "$OUT"
  echo "top_files:" >> "$OUT"
  find "$d/system" -maxdepth 6 -type f 2>/dev/null |
    sed "s#^$d/system#/system#" |
    sort |
    head -120 >> "$OUT" || true
done

section "module file hashes"
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  id="${d##*/}"
  echo "-- $id --" >> "$OUT"
  for f in module.prop sepolicy.rule post-fs-data.sh post-mount.sh service.sh late-load.sh action.sh customize.sh; do
    [ -f "$d/$f" ] || continue
    sha256sum "$d/$f" >> "$OUT" 2>/dev/null || true
  done
done

section "live module mounts"
mount 2>/dev/null |
  grep -Ei '/data/adb/modules|/data/adb/[^ ]+|/system/etc/security/cacerts|/apex/.*/cacerts|overlay|hybrid|magic|kasumi' |
  head -260 >> "$OUT" || true

section "dropbox crash markers"
"$BB" ls -lt /data/system/dropbox/system_server_crash* /data/system/dropbox/system_server_watchdog* /data/system/dropbox/system_server_pre_watchdog* /data/system/dropbox/system_server_anr* 2>/dev/null |
  "$BB" head -30 >> "$OUT" || true
"$BB" ls -lt /data/tombstones 2>/dev/null | "$BB" head -30 >> "$OUT" || true

echo "$OUT"
