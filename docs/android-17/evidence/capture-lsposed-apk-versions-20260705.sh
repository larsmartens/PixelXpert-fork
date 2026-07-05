#!/system/bin/sh
set -u

echo "## lsposed apk package versions"
for pkg in \
  at.gv.oe.idaustriabypass \
  ccc71.at.free \
  com.coderstory.toolkit \
  com.fankes.apperrorstracking \
  com.kieronquinn.app.classicpowermenu \
  com.wmods.wppenhacer \
  com.yureitzk.nophotopickerapi \
  eu.hxreborn.amznkiller \
  eu.hxreborn.discoveradsfilter \
  eu.hxreborn.remembermysort \
  eu.rafareborn.biometricbypass \
  io.github.vvb2060.callrecording \
  ltd.nextalone.pkginstallerplus \
  org.frknkrc44.hma_oss \
  org.klab.batteryinfo \
  ru.buruobtd.xlduivqjb \
  ru.mike.updatelocker \
  sh.siava.pixelxpert; do
  echo "### $pkg"
  dumpsys package "$pkg" 2>/dev/null | grep -E 'versionName=|versionCode=|firstInstallTime=|lastUpdateTime=|installerPackageName=|codePath=' || echo "not installed"
done

echo
echo "## possible root manager packages"
pm list packages 2>/dev/null | grep -Ei 'kernel|kernelsu|ksu|root|apatch|magisk' || true
