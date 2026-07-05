#!/system/bin/sh
set -eu

BASE=/data/adb/pixelxpert-stage
TS=$(date +%Y%m%d-%H%M%S)
WORK="$BASE/play-integrity-minimal-stack-$TS"
ROLLBACK="$WORK/rollback-restore-modules.sh"
MODULES=/data/adb/modules

# Keep only the components needed for a minimal Play Integrity test.
KEEP=" zygisksu playintegrityfix tricky_store "

echo "## context"
date
id
uname -a
mkdir -p "$WORK"
chmod 700 "$BASE" "$WORK" 2>/dev/null || true

echo "#!/system/bin/sh" > "$ROLLBACK"
echo "set -eu" >> "$ROLLBACK"
echo "MODULES=$MODULES" >> "$ROLLBACK"

echo
echo "## module isolation"
for d in "$MODULES"/*; do
  [ -d "$d" ] || continue
  id=$(basename "$d")
  case "$KEEP" in
    *" $id "*) echo "keep=$id"; continue ;;
  esac

  if [ -e "$d/disable" ]; then
    echo "already_disabled=$id"
    echo "[ -e \"\$MODULES/$id/disable\" ] || : # was already disabled" >> "$ROLLBACK"
  else
    echo "disable=$id"
    touch "$d/disable"
    echo "rm -f \"\$MODULES/$id/disable\"" >> "$ROLLBACK"
  fi
done

chmod 700 "$ROLLBACK"
echo
echo "rollback=$ROLLBACK"
echo "Reboot required for module isolation to take effect."
