#!/system/bin/sh
set -u

echo "## context"
date
id
getprop ro.build.fingerprint
getprop ro.boot.verifiedbootstate
getprop ro.boot.flash.locked
pidof com.google.android.gms || true
pidof com.google.android.gms.unstable || true
pidof com.android.vending || true

echo
echo "## module-summary"
for d in /data/adb/modules/playintegrityfix /data/adb/modules/tricky_store /data/adb/modules/zygisksu /data/adb/modules/zygisk_nohello; do
  echo "### $d"
  if [ -d "$d" ]; then
    sed -n '1,80p' "$d/module.prop" 2>/dev/null
    for marker in disable remove skip_mount; do
      [ -e "$d/$marker" ] && ls -lZ "$d/$marker" 2>/dev/null
    done
  else
    echo "missing"
  fi
done

echo
echo "## config-paths-redacted"
for root in /data/adb /data/adb/modules/tricky_store /data/adb/modules/playintegrityfix /data/adb/modules/zygisksu; do
  [ -e "$root" ] || continue
  echo "### $root"
  find "$root" -maxdepth 4 \( -iname '*tricky*' -o -iname '*tee*' -o -iname '*keybox*' -o -iname '*target*' -o -iname '*pif*' -o -iname '*zygisk*' \) -print 2>/dev/null | sort
done

echo
echo "## safe-config-content"
for f in \
  /data/adb/tricky_store/target.txt \
  /data/adb/tricky_store/security_patch.txt \
  /data/adb/modules/tricky_store/target.txt \
  /data/adb/modules/playintegrityfix/pif.prop \
  /data/adb/modules/playintegrityfix/custom.pif.prop \
  /data/adb/modules/playintegrityfix/custom.pif.json \
  /data/adb/modules/playintegrityfix/autopif4/pif.prop \
  /data/adb/modules/playintegrityfix/autopif4/custom.pif.prop \
  /data/adb/modules/playintegrityfix/autopif4/custom.pif.json; do
  echo "### $f"
  if [ -f "$f" ]; then
    ls -lZ "$f"
    sha256sum "$f"
    case "$f" in
      *keybox*|*.pem|*.der|*.p12|*.pfx) echo "content=redacted" ;;
      *) sed -n '1,160p' "$f" ;;
    esac
  else
    echo "missing"
  fi
done

echo
echo "## keybox-presence-redacted"
for f in /data/adb/tricky_store/keybox.xml /data/adb/modules/tricky_store/keybox.xml; do
  echo "### $f"
  if [ -f "$f" ]; then
    ls -lZ "$f"
    sha256sum "$f"
    echo "content=redacted"
  else
    echo "missing"
  fi
done

echo
echo "## recent-integrity-logcat"
logcat -d -t 5000 2>/dev/null | grep -Ei 'PlayIntegrity|DroidGuard|tricky|TEESimulator|keybox|keystore2|zygisk|pif|gms.unstable|StrongBox|attest' | tail -n 300
