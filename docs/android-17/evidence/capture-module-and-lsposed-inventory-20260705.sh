#!/system/bin/sh
set -eu

echo "## modules"
for prop in /data/adb/modules/*/module.prop; do
  [ -f "$prop" ] || continue
  module_dir="$(dirname "$prop")"
  module_id="$(basename "$module_dir")"
  state="enabled"
  [ -f "$module_dir/disable" ] && state="disabled"
  skip_mount="no"
  [ -f "$module_dir/skip_mount" ] && skip_mount="yes"
  echo "### $module_id"
  echo "state=$state"
  echo "skip_mount=$skip_mount"
  grep -E '^(id|name|version|versionCode|author|description|updateJson)=' "$prop" || true
done

echo "## lsposed_candidates"
find /data/adb -maxdepth 10 \
  \( -iname '*lsp*' -o -iname '*scope*' -o -iname '*.db' -o -iname '*.json' \) \
  -print 2>/dev/null | sort

echo "## zygisk_processes"
ps -A -o USER,PID,NAME,ARGS 2>/dev/null | grep -E '(zygisk|lspd|lsposed|zygote)' | grep -v grep || true
