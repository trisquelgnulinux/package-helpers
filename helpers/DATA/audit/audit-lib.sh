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
# Golden-master auditing for package helpers.  Sourced by ./config only when
# HELPER_AUDIT is set, so a normal build is completely unaffected.
#
# The idea: capture what a helper changes in the source tree (an "index"),
# freeze it as a signed baseline on a known-good branch (Ecne), and on the
# next branch (Xolotl) compare a fresh run against it to catch effects that
# silently shrank because upstream moved.
#

AUDIT_LIBDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$AUDIT_LIBDIR/audit-common.sh"   # AUDIT_MARK, audit_body (single source of format)
# Baselines live in their own subtree (output), separate from each package's
# DATA/<pkg> (input). Still under DATA/, so the watchdog3 ignores it.
AUDIT_GOLDEN="$(dirname "$AUDIT_LIBDIR")/golden"
# Set variable to track drift changes.
AUDIT_DRIFT_FOUND=0

# Print the upstream version apt would fetch, WITHOUT downloading the tarball,
# so freeze.sh makes an incremental comparison against the baseline's
# upstream-version.  We read the FULL version from `apt-cache showsrc`, INCLUDING
# the epoch, and pick the highest with dpkg. Keeping the epoch to compare versions
# on the same level.
audit_probe(){
  local ver="" v
  if [ -n "${FIXED_VER:-}" ]; then
    ver="$FIXED_VER"
  else
    while read -r v; do
      [ -z "$v" ] && continue
      if [ -z "$ver" ] || dpkg --compare-versions "$v" gt "$ver"; then ver="$v"; fi
    done < <(apt-cache showsrc "$PACKAGE" -c "${LOCAL_APT}/etc/apt.conf" 2>/dev/null \
             | sed -n 's/^Version: //p')
  fi
  echo "AUDIT_PROBE_VERSION=$ver"
  exit 0
}

# Take the "before" snapshot: the tree the helper is about to transform,
# with upstream patches not yet applied, and config's own edits in place.
# Diffing this against audit_end isolates the helper's own effect.
audit_begin(){
  [ -n "${AUDIT_REACHED:-}" ] && : > "$AUDIT_REACHED"
  # AUDIT_TMP is cleaned by config's EXIT trap too, so the compressed blob
  # store (GBs for firefox) never leaks if the build aborts before audit_end.
  export AUDIT_TMP="$(mktemp -d)"
  export AUDIT_GIT="$AUDIT_TMP/git"
  git --git-dir="$AUDIT_GIT" --work-tree=. init -q
  # -Af + empty excludesFile: count EVERYTHING the helper touches, even paths an
  # upstream .gitignore would hide -- otherwise such edits look like a no-op.
  git --git-dir="$AUDIT_GIT" --work-tree=. -c core.excludesFile=/dev/null add -Af
  git --git-dir="$AUDIT_GIT" --work-tree=. \
      -c user.email=audit@local -c user.name=audit commit -q -m before
}

# Produce the manifest of the helper's effect: one line per changed file.
audit_manifest(){
  # Stage first so newly-created files show up too (plain `git diff HEAD`
  # ignores untracked files, which would silently drop files a helper adds).
  git --git-dir="$AUDIT_GIT" --work-tree=. -c core.excludesFile=/dev/null add -Af
  git --git-dir="$AUDIT_GIT" --work-tree=. diff --numstat --cached HEAD \
      -- . ':(exclude).pc' ':(exclude)debian/changelog' \
    | awk -F'\t' 'BEGIN{OFS="\t"}
        { a=$1; r=$2; if(a=="-")a="bin"; if(r=="-")r="bin"; print a,r,$3 }' \
    | LC_ALL=C sort -t"$(printf '\t')" -k3,3
}

# Provenance header written on top of a baseline when it is blessed.
audit_stamp(){
  # Who blessed it: the git email (git config user.email) of the committer,
  # falls back to "unknown" if none is configured.
  local blesser authorized
  blesser="${AUDIT_BLESSER:-$(git config user.email 2>/dev/null || git config user.name 2>/dev/null)}"
  # 'yes' ONLY under AUDIT_BLESS=1 (or a later bless.sh).  A plain run that
  # rewrites a drifted golden stays 'no', so a casual `git add -A && commit`
  # cannot authorize drift without a conscious act.  verify.sh enforces this.
  [ "${AUDIT_BLESS:-}" = 1 ] && authorized=yes || authorized=no
  # NOTE: this checksum ties header to body for COHERENCE (catch a stray hand
  # edit).  It is not a signature and is not meant to resist tampering.
  echo "# trisquel golden manifest — auto-generated; checksum keeps header and body coherent."
  echo "# Do not edit by hand: it is rewritten on every build and re-checksummed."
  echo "# package:      $PACKAGE"
  echo "# blessed-by:   ${blesser:-unknown}"
  echo "# blessed-at:   $(date -Iseconds)"
  echo "# upstream:     ${UPSTREAM:-?} (${UPSTREAMRELEASE:-?})  helper-version: ${VERSION:-?}"
  # FULL version, epoch included: 2:1.1 must NOT compare equal to 1:1.1.
  echo "# upstream-version: ${UPSTREAMVERSION:-?}"
  echo "# authorized:  $authorized"
  echo "# body-sha256-checksum:  $1"
}

# audit_body() and AUDIT_MARK are provided by audit-common.sh (sourced above).

# Write a signed baseline from a fresh manifest.
audit_write_golden(){
  local out="$1" fresh="$2" h
  h="$(sha256sum < "$fresh" | cut -d' ' -f1)"
  mkdir -p "$(dirname "$out")"
  { audit_stamp "$h"; echo "$AUDIT_MARK"; cat "$fresh"; } > "$out"
}

# Apply the audit: compare the fresh effect against the COMMITTED baseline
# (git HEAD, not the on-disk file — so writing the golden below doesn't erase
# the drift signal on the next build), (re)write the signed golden into the
# working tree ONLY when the effect changed (so `git diff -- DATA/golden/<pkg>`
# shows exactly what changed and OK builds stay clean), set the greppable
# AUDIT_VERDICT, and STOP the build on DRIFT unless it was blessed/forced.
#
#   AUDIT_BLESS=1  -> sign and proceed (no stop) even on drift
#   AUDIT_STRICT=0 -> monitor: report only, never stops (Jenkins/CI)
#   AUDIT_FORCE=1  -> let a single build through without blessing
# Default (no vars): strict — a drift stops the build.
audit_apply(){
  local fresh="$1" gdir golden craw cbody diff d s n
  gdir="$AUDIT_GOLDEN/$PACKAGE"; golden="$gdir/manifest.tsv"
  craw="$(mktemp)"
  # existence is git show's exit code -- an empty body is a valid baseline
  # (some helpers change nothing), so we must not treat "empty" as "missing".
  if ! git -C "$gdir" show "HEAD:./manifest.tsv" > "$craw" 2>/dev/null; then
    rm -f "$craw"                      # no committed baseline yet -> establish it
    audit_write_golden "$golden" "$fresh"
    AUDIT_VERDICT="audit: baseline written (DATA/golden/$PACKAGE)"
    return 0
  fi
  cbody="$(mktemp)"; audit_body "$craw" > "$cbody"; rm -f "$craw"
  if cmp -s "$cbody" "$fresh"; then    # unchanged -> leave the golden as committed
    rm -f "$cbody"
    AUDIT_VERDICT="audit: OK, no changes vs baseline"
    return 0
  fi

  audit_write_golden "$golden" "$fresh"          # effect changed -> rewrite, signed
  diff=$(python3 "$AUDIT_LIBDIR/compare.py" "$cbody" "$fresh" || true)
  rm -f "$cbody"
  # One pass, no reliance on grep -c's exit code under set -e.
  read -r d s n < <(printf '%s\n' "$diff" | awk '
      /^DROPPED/{d++} /^SHRUNK|^INVERTED/{s++} /^NEW/{n++}
      END{print d+0, s+0, n+0}')
  if [ "$d" -gt 0 ] || [ "$s" -gt 0 ]; then
    AUDIT_VERDICT="audit: DRIFT — dropped=$d shrunk=$s new=$n  (review: git diff -- DATA/golden/$PACKAGE)"
    if [ "${AUDIT_BLESS:-}" != 1 ] && [ "${AUDIT_STRICT:-1}" != 0 ] && [ "${AUDIT_FORCE:-}" != 1 ]; then
      # Do NOT call audit_report here: it is the single gate at the end of
      # package().  We only set the flag; the verdict prints there once.
      echo "E: [audit] $PACKAGE — drift vs baseline; build stopped." 1>&2
      echo "   review:  git diff -- DATA/golden/$PACKAGE" 1>&2
      echo "   accept:  AUDIT_BLESS=1 bash make-$PACKAGE   (signs + builds), then commit the golden." 1>&2
      echo "WARNING: Packing will continue, but process will abort afterwards."
      AUDIT_DRIFT_FOUND=1
    fi
  else
    AUDIT_VERDICT="audit: changed — new=$n  (review: git diff -- DATA/golden/$PACKAGE)"
  fi
}

# Print the verdict as one greppable line.  Called from config's package(), at
# the very end -- next to "source package built" and the distro-match notes,
# which is where the eye lands when a helper run finishes.
audit_report(){
  [ -n "${AUDIT_VERDICT:-}" ] && echo "> ${AUDIT_VERDICT}"
  if [ "$AUDIT_DRIFT_FOUND" = "1" ]; then
    echo "ERROR: Aborting execution due to audit drift detected earlier."
    exit 1
  fi
  return 0
}

# Close the audit: build the manifest, then either bless (write baseline) or
# gate (compare).  Called from the top of package(), before quilt applies
# patches, so the diff is the helper's effect only.
audit_end(){
  [ -n "${AUDIT_GIT:-}" ] || return 0
  local fresh; fresh="$(mktemp)"
  audit_manifest > "$fresh"
  rm -rf "$(dirname "$AUDIT_GIT")"
  audit_apply "$fresh"
  rm -f "$fresh"
}
