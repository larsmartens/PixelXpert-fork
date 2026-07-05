#!/system/bin/sh
set -eu

for module in PixelXpert zygisk_lsposed zygisksu playintegrityfix tricky_store rezygisk nohello; do
  path="/data/adb/modules/$module"
  if [ -d "$path" ]; then
    if [ -f "$path/disable" ]; then
      state="disabled"
    else
      state="enabled"
    fi
    version=""
    if [ -f "$path/module.prop" ]; then
      version="$(grep -E '^(version|versionCode)=' "$path/module.prop" 2>/dev/null | tr '\n' ' ')"
    fi
    printf '%s\t%s\t%s\n' "$module" "$state" "$version"
  fi
done
