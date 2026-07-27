#!/bin/bash
#
#    Copyright (C) 2026  Luis Guzman <ark@switnet.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
# Bless the CURRENT on-disk golden(s) WITHOUT re-running the helper.
#
# For long helpers (firefox, linux, ...) whose LAST `HELPER_AUDIT` run already
# produced the desired manifest -- left as `authorized: no` because it drifted
# and was not blessed inline -- and whose compiled result was verified good:
# re-stamp DATA/golden/<pkg>/manifest.tsv as `authorized: yes` with a coherent
# checksum.  Rebuilds nothing; it trusts the manifest the last run wrote.
#
# The point of the audit is that authorization is a CONSCIOUS act: a plain run
# never leaves `yes`, so a casual `git add -A` cannot bless drift by accident.
# This script IS that conscious act, minus the hours of recompilation.
#
#   bash helpers/DATA/audit/bless.sh firefox           # or: make-firefox
#   bash helpers/DATA/audit/bless.sh linux firefox ...
#
# Review before committing:  git diff -- DATA/golden/

set -eu
cd "$(dirname "$0")/../.."
. DATA/audit/audit-common.sh

[ "$#" -gt 0 ] || { echo "usage: bless.sh <pkg|make-pkg> ..." >&2; exit 2; }
blesser="${AUDIT_BLESSER:-$(git config user.email 2>/dev/null || echo unknown)}"

field(){ sed -n "s/^# $1:[[:space:]]*//p" "$2" | head -1; }

blessed=0
for a in "$@"; do
  pkg=${a#make-}
  g="DATA/golden/$pkg/manifest.tsv"
  if [ ! -f "$g" ]; then
    echo "SKIP    $pkg (no golden; run 'HELPER_AUDIT=1 bash make-$pkg' once first)"
    continue
  fi

  # Checksum the body EXACTLY as verify.sh will read it back, so the stamp
  # stays coherent.  The body itself is untouched -- only the header changes.
  bodyf=$(mktemp); audit_body "$g" > "$bodyf"
  h=$(sha256sum < "$bodyf" | cut -d' ' -f1)
  pk=$(field package "$g"); up=$(field upstream "$g"); uv=$(field upstream-version "$g")
  {
    echo "# trisquel golden manifest — auto-generated; checksum keeps header and body coherent."
    echo "# Do not edit by hand: it is rewritten on every build and re-checksummed."
    echo "# package:      ${pk:-$pkg}"
    echo "# blessed-by:   $blesser"
    echo "# blessed-at:   $(date -Iseconds)"
    echo "# upstream:     ${up:-?}"
    echo "# upstream-version: ${uv:-?}"
    echo "# authorized:  yes"
    echo "# body-sha256-checksum:  $h"
    echo "$AUDIT_MARK"
    cat "$bodyf"
  } > "$g.tmp" && mv "$g.tmp" "$g"
  rm -f "$bodyf"
  echo "BLESSED $pkg  ($g)"
  blessed=$((blessed + 1))
done

echo "----"
echo "bless: $blessed golden(s) authorized.  Review: git diff -- DATA/golden/   then commit."
