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
# Integrity check for the golden baselines.
# Suitable for a pre-commit hook or a CI job.  It fails (exit != 0) if either:
#   1. a baseline body no longer matches its signed body-sha256 (someone
#      edited a golden by hand, or `git add .`-ed a change, without blessing);
#   2. a golden exists for a helper that is no longer present (orphan).
#
# Lives under DATA/ (invisible to the trisquel-builder watchdog) and cd's to
# the helpers/ root itself:  bash helpers/DATA/audit/verify.sh

set -u
cd "$(dirname "$0")/../.."

. "$(dirname "$0")/audit-common.sh"   # AUDIT_MARK, audit_body

fail=0
found=0
for g in DATA/golden/*/manifest.tsv; do
  [ -e "$g" ] || continue
  found=$((found + 1))
  pkg=$(echo "$g" | cut -d/ -f3)
  # $NF tolerates both the old '# body-sha256:' and new '# body-sha256-checksum:'.
  want=$(awk '/^# body-sha256/{print $NF}' "$g")
  got=$(audit_body "$g" | sha256sum | cut -d' ' -f1)
  auth=$(sed -n 's/^# authorized:[[:space:]]*//p' "$g")
  if [ "$want" != "$got" ]; then
    echo "MISMATCH  $pkg  ($g)  header checksum != body"; fail=1
  elif [ ! -f "make-$pkg" ]; then
    echo "ORPHAN    $pkg  (golden without make-$pkg)"; fail=1
  elif [ "$auth" = no ]; then
    # legacy goldens have no 'authorized' line -> grandfathered (auth empty).
    echo "UNBLESSED $pkg  drift not blessed -> bash DATA/audit/bless.sh $pkg"; fail=1
  fi
done

[ "$fail" = 0 ] && echo "audit-verify: ok ($found baselines)"
exit $fail
