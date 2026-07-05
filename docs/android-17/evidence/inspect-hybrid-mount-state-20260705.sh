#!/system/bin/sh
set -eu

BB=/data/adb/ksu/bin/busybox
if [ ! -x "$BB" ]; then
  BB=busybox
fi

echo "== identity =="
id
getenforce 2>/dev/null || true

echo "== installed mount/meta modules =="
/data/adb/ksu/bin/ksud module list 2>/dev/null \
  | "$BB" grep -Ei '"id":"([^"]*(hybrid|overlay|magic|mountify|susfs)[^"]*)"' || true

echo "== hybrid data directory =="
"$BB" find /data/adb/hybrid-mount -maxdepth 2 -printf '%M %u:%g %p\n' 2>/dev/null || true
for f in \
  /data/adb/hybrid-mount/config.toml \
  /data/adb/hybrid-mount/module_blacklist.toml \
  /data/adb/hybrid-mount/run/daemon_state.json
do
  [ -e "$f" ] && "$BB" sha256sum "$f" || true
done

echo "== hybrid config excerpt =="
"$BB" sed -n '1,140p' /data/adb/hybrid-mount/config.toml 2>/dev/null || true

echo "== hybrid blacklist excerpt =="
"$BB" sed -n '1,80p' /data/adb/hybrid-mount/module_blacklist.toml 2>/dev/null || true

echo "== active process hints =="
"$BB" ps -A -o USER,PID,PPID,NAME,ARGS 2>/dev/null \
  | "$BB" grep -Ei 'hybrid|overlayfs|mountify|magic_mount|kasumi' \
  | "$BB" grep -v grep || true

echo "== active mount hints =="
"$BB" mount 2>/dev/null \
  | "$BB" grep -Ei 'hybrid|overlay|kasumi|PixelXpert|adguardcert|/data/adb/modules' || true

echo "== module marker matrix =="
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  id="${d##*/}"
  disable=0
  skip_mount=0
  mount_error=0
  system=0
  [ -e "$d/disable" ] && disable=1
  [ -e "$d/skip_mount" ] && skip_mount=1
  [ -e "$d/mount_error" ] && mount_error=1
  [ -d "$d/system" ] && system=1
  printf '%s disable=%s skip_mount=%s mount_error=%s system=%s\n' \
    "$id" "$disable" "$skip_mount" "$mount_error" "$system"
done
