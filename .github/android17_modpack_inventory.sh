#!/usr/bin/env bash
set -euo pipefail

inventory="docs/android-17/hook-inventory.tsv"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

{
  printf 'annotation\ttarget_package\tandroid17_policy\tmain_process\tchild_process\tchild_process_contains\tclass\tsource\n'
  perl -0ne '
    while (/((?:\s*\@\w+(?:\([^\n]*\))?[^\n]*\n)+)\s*public\s+class\s+(\w+)/g) {
      my ($anns, $class)=($1,$2);
      while ($anns =~ /\@(CommonModPack|FrameworkModPack|TelecomServerModPack|SystemUIModPack|LauncherModPack|DialerModPack|SettingsModPack|KSUModPack|KSUNextModPack)\b/g) {
        my $ann=$1;
        my $main=($anns =~ /\@ChildProcessModPack\b/ && $anns !~ /\@MainProcessModPack\b/) ? "false" : "true";
        my $child=($anns =~ /\@ChildProcessModPack\b/) ? "true" : "false";
        my $childName="";
        $childName=$1 if $anns =~ /\@ChildProcessModPack\(processNameContains\s*=\s*"([^"]*)"\)/;
        my %target=(
          CommonModPack=>"common",
          FrameworkModPack=>"android",
          TelecomServerModPack=>"com.android.server.telecom",
          SystemUIModPack=>"com.android.systemui",
          LauncherModPack=>"com.google.android.apps.nexuslauncher",
          DialerModPack=>"com.google.android.dialer",
          SettingsModPack=>"com.android.settings",
          KSUModPack=>"me.weishu.kernelsu",
          KSUNextModPack=>"com.rifsxd.ksunext"
        );
        my %policy=(
          CommonModPack=>"blocked",
          FrameworkModPack=>"blocked",
          TelecomServerModPack=>"blocked",
          SystemUIModPack=>"manual-scope",
          LauncherModPack=>"manual-scope",
          DialerModPack=>"manual-scope",
          SettingsModPack=>"manual-scope",
          KSUModPack=>"manual-scope",
          KSUNextModPack=>"manual-scope"
        );
        print "$ann\t$target{$ann}\t$policy{$ann}\t$main\t$child\t$childName\t$class\t$ARGV\n";
      }
    }
  ' $(find app/src/main/java/sh/siava/pixelxpert/xposed/modpacks -type f -name '*.java' | sort) \
    | sort -t "$(printf '\t')" -k1,1 -k7,7 -k8,8
} > "$tmp"

if ! diff -u "$inventory" "$tmp"; then
  echo "Android 17 modpack inventory is stale. Update $inventory after reviewing hook policy." >&2
  exit 1
fi

awk -F '\t' '
  NR == 1 { next }
  $1 == "CommonModPack" && $3 != "blocked" { print "CommonModPack must be blocked on Android 17: " $0; bad=1 }
  $1 == "FrameworkModPack" && $3 != "blocked" { print "FrameworkModPack must be blocked on Android 17: " $0; bad=1 }
  $1 == "TelecomServerModPack" && $3 != "blocked" { print "TelecomServerModPack must be blocked on Android 17: " $0; bad=1 }
  $1 ~ /^(SystemUIModPack|LauncherModPack|DialerModPack|SettingsModPack|KSUModPack|KSUNextModPack)$/ && $3 != "manual-scope" {
    print "Package modpack must be manual-scope on Android 17: " $0
    bad=1
  }
  END { exit bad ? 1 : 0 }
' "$inventory"
