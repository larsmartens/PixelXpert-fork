#!/system/bin/sh
set -u

echo "== module markers =="
ls -la /data/adb/modules/PixelXpert 2>/dev/null || true
echo "== module files =="
find /data/adb/modules/PixelXpert -maxdepth 3 -type f 2>/dev/null | sort | sed -n '1,200p'
echo "== mountinfo =="
grep -i PixelXpert /proc/self/mountinfo 2>/dev/null || true
echo "== lspd logs =="
ls -lt /data/adb/lspd/log 2>/dev/null || true
for f in /data/adb/lspd/log/verbose_* /data/adb/lspd/log/modules_*; do
  [ -f "$f" ] || continue
  echo "== tail $f =="
  tail -220 "$f" 2>/dev/null | grep -Ei 'PixelXpert|sh\.siava\.pixelxpert|ScreenGestures|StatusbarGestures|KeyguardMods|Hook failure|Start Error Dump|KSUInjector|grant root|error|fail' || true
done
echo "== lspd db copy =="
cp /data/adb/lspd/config/modules_config.db /data/local/tmp/modules_config.inspect.db 2>/dev/null || true
chown shell:shell /data/local/tmp/modules_config.inspect.db 2>/dev/null || true
chmod 0644 /data/local/tmp/modules_config.inspect.db 2>/dev/null || true
ls -lZ /data/local/tmp/modules_config.inspect.db 2>/dev/null || true
