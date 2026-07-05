#!/system/bin/sh
set -u

section() {
  echo
  echo "## $1"
}

safe_file_summary() {
  f="$1"
  [ -e "$f" ] || return 0
  case "$f" in
    *keybox*|*Keybox*|*.pem|*.crt|*.cer|*.der|*.p12|*.pfx|*private*|*secret*)
      ls -lZ "$f" 2>/dev/null
      sha256sum "$f" 2>/dev/null
      echo "content=redacted"
      ;;
    *)
      ls -lZ "$f" 2>/dev/null
      sha256sum "$f" 2>/dev/null
      case "$f" in
        *.sh|*.txt|*.prop|*.json|*.toml|*.conf|*.list)
          if [ -f "$f" ]; then
            sed -n '1,120p' "$f" 2>/dev/null
          fi
          ;;
        *)
          echo "content=not-text-or-not-needed"
          ;;
      esac
      ;;
  esac
}

section "context"
date
id
getprop ro.build.fingerprint
getprop ro.build.version.sdk
getprop ro.boot.verifiedbootstate
getprop ro.boot.flash.locked
getprop sys.boot_completed
getprop init.svc.bootanim
ps -A | grep -E 'system_server|zygote|keystore2|gms|vending|systemui' | head -n 80

section "integrity-checker-packages"
pm list packages -U | grep -Ei 'integrity|safety|safetynet|yasnac|attestation|checker|spic|playintegrity' | sort

section "root-modules"
for d in /data/adb/modules/*; do
  [ -d "$d" ] || continue
  name="${d##*/}"
  case "$name" in
    playintegrityfix|tricky_store|zygisksu|zygisk_lsposed|zygisk_nohello|zygisk-detach|rvmm-zygisk-mount|PixelXpert|hybrid_mount)
      echo
      echo "### $name"
      safe_file_summary "$d/module.prop"
      for marker in disable remove skip_mount update; do
        [ -e "$d/$marker" ] && ls -lZ "$d/$marker" 2>/dev/null
      done
      ;;
  esac
done

section "pif-files"
for f in /data/adb/modules/playintegrityfix/* /data/adb/modules/playintegrityfix/.*
do
  [ -e "$f" ] || continue
  [ -d "$f" ] && continue
  case "${f##*/}" in .|..) continue ;; esac
  echo
  echo "### $f"
  safe_file_summary "$f"
done

section "tricky-store-redacted"
for f in /data/adb/tricky_store/* /data/adb/modules/tricky_store/* /data/adb/modules/tricky_store/.*
do
  [ -e "$f" ] || continue
  [ -d "$f" ] && continue
  case "${f##*/}" in .|..) continue ;; esac
  echo
  echo "### $f"
  safe_file_summary "$f"
done

section "zygisk-next-files"
for f in /data/adb/modules/zygisksu/* /data/adb/modules/zygisksu/.*
do
  [ -e "$f" ] || continue
  [ -d "$f" ] && continue
  case "${f##*/}" in .|..) continue ;; esac
  echo
  echo "### $f"
  safe_file_summary "$f"
done

section "kernel-su-state"
ksud -V 2>&1 || true
ksud module list 2>&1 || true
pm list packages | grep -E 'me.weishu.kernelsu|com.rifsxd.ksunext' || true

section "mount-and-denial-state"
grep -E 'zygisk|tricky|playintegrity|PixelXpert|hybrid|susfs|ksu' /proc/self/mountinfo 2>/dev/null | head -n 160
logcat -d -t 2500 2>/dev/null | grep -Ei 'PlayIntegrity|DroidGuard|tricky|teesim|tee simulator|keybox|keystore2|zygisk|denylist|nohello|pif|gms|vending|avc: denied' | tail -n 300

section "dropbox-and-tombstones"
ls -1t /data/system/dropbox/system_server_* 2>/dev/null | head -n 8
ls -lZ /data/tombstones 2>/dev/null | tail -n 16
