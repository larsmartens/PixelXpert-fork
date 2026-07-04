#!/system/bin/sh
set -u

echo "## context"
date
id
echo "latest audit lines:"
logcat -d -t 800 2>/dev/null | grep l53202 | tail -n 12

echo
echo "## direct paths"
for p in \
  /data/l53202 \
  /data/media/l53202 \
  /data/media/0/l53202 \
  /data_mirror/data_ce/null/0/l53202 \
  /mnt/pass_through/0/emulated/l53202 \
  /mnt/pass_through/0/emulated/0/l53202; do
  echo "### $p"
  ls -laiZ "$p" 2>/dev/null || echo "missing-or-inaccessible"
done

echo
echo "## directory heads"
for p in \
  /data \
  /data/media \
  /data/media/0 \
  /data_mirror/data_ce/null/0 \
  /mnt/pass_through/0/emulated \
  /mnt/pass_through/0/emulated/0; do
  echo "### $p"
  ls -laidZ "$p" 2>/dev/null || true
  ls -laiZ "$p" 2>/dev/null | head -n 80
done

echo
echo "## inode scan"
for p in /data /data_mirror /mnt/pass_through /mnt/runtime; do
  [ -e "$p" ] || continue
  echo "### $p"
  find "$p" -xdev \( -inum 30366 -o -inum 30362 -o -name l53202 \) -ls 2>/dev/null
done
