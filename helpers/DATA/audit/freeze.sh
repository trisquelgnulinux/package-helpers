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
#   bash helpers/DATA/audit/freeze.sh                 # all helpers
#   bash helpers/DATA/audit/freeze.sh make-emacs ...  # only the listed ones

set -u
cd "$(dirname "$0")/../.."

LOG="DATA/audit/freeze.log"; : > "$LOG"
list=${*:-$(ls make-*)}
ok=0; fail=0; failed=""

for h in $list; do
  printf '%-34s ' "$h"
  if HELPER_AUDIT=1 AUDIT_BLESS=1 bash "$h" >>"$LOG" 2>&1; then
    echo "ok"; ok=$((ok + 1))
  else
    echo "FAIL"; fail=$((fail + 1)); failed="$failed ${h#make-}"
  fi
done

echo "----"
echo "freeze: ok=$ok  fail=$fail   (details in $LOG)"
[ -n "$failed" ] && echo "no baseline (build fails):$failed"
exit 0
