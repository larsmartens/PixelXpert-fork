#!/system/bin/sh
set -eu

BB=/data/adb/ksu/bin/busybox
[ -x "$BB" ] || BB=busybox
OUT=/data/local/tmp/adguardcert-baseline-validation.txt
: > "$OUT"

section() {
  echo >> "$OUT"
  echo "== $1 ==" >> "$OUT"
}

cert_dir_summary() {
  p="$1"
  echo "-- $p --" >> "$OUT"
  if [ ! -d "$p" ]; then
    echo "missing" >> "$OUT"
    return
  fi
  echo "count=$(find "$p" -maxdepth 1 -type f -name '*.0' 2>/dev/null | wc -l)" >> "$OUT"
  ls -ldZ "$p" >> "$OUT" 2>/dev/null || ls -ld "$p" >> "$OUT" 2>/dev/null || true
  find "$p" -maxdepth 1 -type f -name '*.0' 2>/dev/null |
    sort |
    head -20 >> "$OUT" || true
}

section "identity"
date >> "$OUT"
id >> "$OUT"
getprop sys.boot_completed >> "$OUT"
getprop ro.build.version.sdk >> "$OUT"
getprop ro.build.fingerprint >> "$OUT"

section "adguard packages"
pm list packages | grep -Ei 'adguard|adg' | sort >> "$OUT" || true
for p in com.adguard.android com.adguard.vpn com.adguard.dns; do
  dumpsys package "$p" 2>/dev/null |
    grep -E 'Package \[|versionCode=|versionName=|codePath=|enabled=' |
    head -40 >> "$OUT" || true
done

section "adguardcert module"
if [ -d /data/adb/modules/adguardcert ]; then
  sed -n '/^id=/p;/^name=/p;/^version=/p;/^versionCode=/p;/^author=/p;/^updateJson=/p' /data/adb/modules/adguardcert/module.prop >> "$OUT"
  [ -e /data/adb/modules/adguardcert/disable ] && echo disabled >> "$OUT" || echo enabled >> "$OUT"
  [ -e /data/adb/modules/adguardcert/skip_mount ] && echo skip_mount=1 >> "$OUT" || true
  for f in module.prop post-fs-data.sh post-mount.sh service.sh late-load.sh action.sh common.sh; do
    [ -f "/data/adb/modules/adguardcert/$f" ] || continue
    sha256sum "/data/adb/modules/adguardcert/$f" >> "$OUT" 2>/dev/null || true
  done
else
  echo "missing" >> "$OUT"
fi

section "cert directories"
cert_dir_summary /system/etc/security/cacerts
cert_dir_summary /apex/com.android.conscrypt/cacerts
for d in /apex/com.android.conscrypt@*/cacerts; do
  [ -d "$d" ] || continue
  cert_dir_summary "$d"
done
cert_dir_summary /data/adb/modules/adguardcert/system/etc/security/cacerts
cert_dir_summary /data/adb/adguardcert/cacerts

section "cert dir comparisons"
for src in /data/adb/modules/adguardcert/system/etc/security/cacerts /data/adb/adguardcert/cacerts; do
  [ -d "$src" ] || continue
  for dst in /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts; do
    [ -d "$dst" ] || continue
    src_count=$(find "$src" -maxdepth 1 -type f -name '*.0' 2>/dev/null | wc -l)
    dst_count=$(find "$dst" -maxdepth 1 -type f -name '*.0' 2>/dev/null | wc -l)
    src_tmp=$(mktemp -p /data/local/tmp src.XXXXXX)
    dst_tmp=$(mktemp -p /data/local/tmp dst.XXXXXX)
    find "$src" -maxdepth 1 -type f -name '*.0' -exec basename {} \; 2>/dev/null | sort > "$src_tmp"
    find "$dst" -maxdepth 1 -type f -name '*.0' -exec basename {} \; 2>/dev/null | sort > "$dst_tmp"
    common_count=$(comm -12 "$src_tmp" "$dst_tmp" | wc -l)
    rm -f "$src_tmp" "$dst_tmp"
    echo "$src -> $dst src_count=$src_count dst_count=$dst_count common_names=$common_count" >> "$OUT"
  done
done

section "relevant mounts"
mount 2>/dev/null |
  grep -Ei 'adguard|cacerts|conscrypt|/system/etc/security/cacerts|hybrid|overlay|magic|/data/adb/modules' |
  head -260 >> "$OUT" || true

section "recent crash markers"
"$BB" ls -lt /data/system/dropbox/system_server_crash* /data/system/dropbox/system_server_watchdog* /data/system/dropbox/system_server_pre_watchdog* /data/system/dropbox/system_server_anr* 2>/dev/null |
  "$BB" head -30 >> "$OUT" || true
"$BB" ls -lt /data/tombstones 2>/dev/null | "$BB" head -30 >> "$OUT" || true

echo "$OUT"
