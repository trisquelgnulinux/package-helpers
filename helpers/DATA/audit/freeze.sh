#!/bin/bash
#
#    Copyright (C) 2026  Luis Guzman <ark@switnet.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
# Freeze the golden baselines for every helper on the current branch.
# Runs each make-* under audit in BLESS mode, writing a signed
# DATA/golden/<pkg>/manifest.tsv.  Meant to run on ecne, where every helper
# is known-good.  Helpers that already fail to build are skipped (logged).
#
# Lives under DATA/ so the trisquel-builder watchdog does not mistake it for
# a package helper.  It cd's to the helpers/ root itself, so run it from
# anywhere:
#
# Incremental mode (-i / --incremental): for a helper that already has a
# baseline, probe the current upstream version WITHOUT downloading the tarball
# and skip it if it still matches, so a re-run only touches new/updated packages.
#
#   bash helpers/DATA/audit/freeze.sh                 # all helpers
#   bash helpers/DATA/audit/freeze.sh -i              # only new/updated ones
#   bash helpers/DATA/audit/freeze.sh make-emacs ...  # only the listed ones

set -u
cd "$(dirname "$0")/../.."

incremental=0
args=()
for a in "$@"; do
  case "$a" in
    -i|--incremental) incremental=1 ;;
    *) args+=("$a") ;;
  esac
done
set -- ${args[@]+"${args[@]}"}

LOG="DATA/audit/freeze.log"; : > "$LOG"
# Array + glob instead of an unquoted string: robust if a name ever has spaces.
if [ "$#" -gt 0 ]; then helpers=("$@"); else helpers=(make-*); fi
ok=0; fail=0; uptodate=0; failed=""

for h in "${helpers[@]}"; do
  pkg=${h#make-}
  printf '%-34s ' "$h"

  # Incremental: skip if the baseline already matches the current upstream
  # version (probed without downloading).  No baseline => fall through and run.
  if [ "$incremental" = 1 ] && [ -f "DATA/golden/$pkg/manifest.tsv" ]; then
    recorded=$(awk '/^# upstream-version:/{print $3}' "DATA/golden/$pkg/manifest.tsv")
    current=$(AUDIT_PROBE=1 bash "$h" </dev/null 2>>"$LOG" \
              | sed -n 's/^AUDIT_PROBE_VERSION=//p' | tail -1)
    if [ -n "$current" ] && [ "$current" = "$recorded" ]; then
      echo "up-to-date ($current)"; uptodate=$((uptodate + 1)); continue
    fi
    echo -n "update ${recorded:-?} -> ${current:-?} ... "
  fi

  if HELPER_AUDIT=1 AUDIT_BLESS=1 bash "$h" >>"$LOG" 2>&1; then
    echo "ok"; ok=$((ok + 1))
  else
    echo "FAIL"; fail=$((fail + 1)); failed="$failed $pkg"
  fi
done

echo "----"
echo "freeze: ok=$ok  up-to-date=$uptodate  fail=$fail   (details in $LOG)"
[ -n "$failed" ] && echo "no baseline (build fails):$failed"
exit 0
