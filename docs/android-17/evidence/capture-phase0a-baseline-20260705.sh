#!/system/bin/sh
set -u

echo "## context"
date
id
echo "serial=$(getprop ro.serialno)"
echo "device=$(getprop ro.product.device)"
echo "model=$(getprop ro.product.model)"
echo "fingerprint=$(getprop ro.build.fingerprint)"
echo "sdk=$(getprop ro.build.version.sdk)"
echo "boot_completed=$(getprop sys.boot_completed)"
echo "bootanim=$(getprop init.svc.bootanim)"
echo "kernel=$(uname -a)"
command -v ksud >/dev/null 2>&1 && ksud -V 2>&1 || true

echo
echo "## root-core paths"
for p in /data/adb/ksu /data/adb/ksud /data/adb/modules /data/adb/lspd /data/adb/tricky_store; do
  echo "### $p"
  ls -ldZ "$p" 2>&1 || true
done

echo
echo "## package versions"
for pkg in \
  me.weishu.kernelsu \
  io.github.rifsxd.ksunext \
  com.rifsxd.ksunext \
  com.google.android.gms \
  com.android.vending \
  sh.siava.pixelxpert \
  gr.nikolasspyr.integritycheck \
  com.henrikherzig.playintegritychecker \
  io.github.vvb2060.keyattestation; do
  echo "### $pkg"
  dumpsys package "$pkg" 2>/dev/null | grep -E 'versionName=|versionCode=|firstInstallTime=|lastUpdateTime=|installerPackageName=|codePath=|resourcePath=' || true
done

echo
echo "## newest system_server dropbox"
ls -lt /data/system/dropbox/system_server_crash* /data/system/dropbox/system_server_watchdog* /data/system/dropbox/system_server_pre_watchdog* /data/system/dropbox/system_server_anr* 2>/dev/null | head -20 || true

echo
echo "## newest tombstones"
ls -lt /data/tombstones 2>/dev/null | head -20 || true

echo
echo "## integrity config hashes"
for f in \
  /data/adb/modules/playintegrityfix/module.prop \
  /data/adb/modules/tricky_store/module.prop \
  /data/adb/tricky_store/target.txt \
  /data/adb/tricky_store/security_patch.txt \
  /data/adb/tricky_store/keybox.xml \
  /data/adb/pif.json \
  /data/adb/pif.prop; do
  [ -f "$f" ] && sha256sum "$f" && ls -lZ "$f"
done

exit 0
