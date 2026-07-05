#!/system/bin/sh
set -eu

OUT=/data/local/tmp/integrity-stack-summary.txt
: > "$OUT"

echo "== module props ==" >> "$OUT"
for d in /data/adb/modules/*; do
  [ -f "$d/module.prop" ] || continue
  id="${d##*/}"
  case "$id" in
    *tricky*|*pif*|*play*|*integrity*|*tee*|*zygisk*|*nohello*|*susfs*|*shamiko*|*strong*)
      echo "-- $id --" >> "$OUT"
      sed -n '/^id=/p;/^name=/p;/^version=/p;/^versionCode=/p;/^updateJson=/p;/^author=/p' "$d/module.prop" >> "$OUT"
      [ -e "$d/disable" ] && echo disabled >> "$OUT" || echo enabled >> "$OUT"
      [ -e "$d/skip_mount" ] && echo skip_mount=1 >> "$OUT" || true
      find "$d" -maxdepth 2 -type f 2>/dev/null |
        sed "s#^$d/##" |
        grep -Ei '(json|prop|conf|list|txt|action|service|post-fs|post-mount|module.prop)$' |
        sort >> "$OUT" || true
      ;;
  esac
done

echo "== keybox hashes only ==" >> "$OUT"
for f in \
  /data/adb/tricky_store/keybox.xml \
  /data/adb/modules/tricky_store/keybox.xml \
  /data/adb/modules/tricky_store/*keybox* \
  /data/adb/modules/*/*keybox*
do
  [ -f "$f" ] || continue
  echo "$f" >> "$OUT"
  sha256sum "$f" >> "$OUT"
done

echo "== config file names only ==" >> "$OUT"
find /data/adb -maxdepth 4 -type f 2>/dev/null |
  grep -Ei '(tricky|integrity|pif|play|tee|strong|nohello|target|deny|exclude|spoof|verified|fp|fingerprint)' |
  sort -u >> "$OUT" || true

echo "== recent sanitized logs ==" >> "$OUT"
logcat -d -t 7000 |
  grep -Ei 'BadAuthentication|UNAUTHENTICATED|DroidGuard|PlayIntegrity|Attestation|Tricky|keystore2|get_rkpd|keybox|strong' |
  sed -E 's#(<Keybox[^>]*>|-----BEGIN [^-]+-----|[A-Za-z0-9+/]{80,}=*)#[redacted]#g' |
  tail -260 >> "$OUT" || true

echo "$OUT"
