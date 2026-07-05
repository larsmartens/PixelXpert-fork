#!/system/bin/sh
set -u

echo "## pif module files"
for f in \
  /data/adb/modules/playintegrityfix/module.prop \
  /data/adb/modules/playintegrityfix/custom.pif.prop \
  /data/adb/modules/playintegrityfix/custom.pif.prop.bak \
  /data/adb/modules/playintegrityfix/autopif4/pif.prop \
  /data/adb/modules/playintegrityfix/autopif4/custom.pif.prop \
  /data/adb/pif.json \
  /data/adb/pif.prop; do
  [ -f "$f" ] || continue
  echo "### $f"
  ls -lZ "$f"
  sha256sum "$f"
  sed -n '1,160p' "$f"
done

echo
echo "## teesim config hashes"
for f in /data/adb/tricky_store/target.txt /data/adb/tricky_store/security_patch.txt /data/adb/tricky_store/keybox.xml; do
  [ -f "$f" ] || continue
  echo "### $f"
  ls -lZ "$f"
  sha256sum "$f"
  case "$f" in
    *keybox.xml) echo "content=redacted" ;;
    *) sed -n '1,160p' "$f" ;;
  esac
done

echo
echo "## pif commands"
for f in /data/adb/modules/playintegrityfix/action.sh /data/adb/modules/playintegrityfix/killpi.sh /data/adb/modules/playintegrityfix/autopif4.sh; do
  [ -f "$f" ] || continue
  echo "### $f"
  sed -n '1,220p' "$f"
done
