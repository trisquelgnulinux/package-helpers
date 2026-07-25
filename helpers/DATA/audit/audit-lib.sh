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

AUDIT_MARK='--- manifest ---'
AUDIT_LIBDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Baselines live in their own subtree (output), separate from each package's
# DATA/<pkg> (input). Still under DATA/, so the watchdog3 ignores it.
AUDIT_GOLDEN="$(dirname "$AUDIT_LIBDIR")/golden"

# Take the "before" snapshot: the tree the helper is about to transform,
# with upstream patches not yet applied, and config's own edits in place.
# Diffing this against audit_end isolates the helper's own effect.
audit_begin(){
  export AUDIT_GIT="$(mktemp -d)/git"
  git --git-dir="$AUDIT_GIT" --work-tree=. init -q
  git --git-dir="$AUDIT_GIT" --work-tree=. add -A
  git --git-dir="$AUDIT_GIT" --work-tree=. \
      -c user.email=audit@local -c user.name=audit commit -q -m before
}

# Produce the manifest of the helper's effect: one line per changed file.
audit_manifest(){
  # Stage first so newly-created files show up too (plain `git diff HEAD`
  # ignores untracked files, which would silently drop files a helper adds).
  git --git-dir="$AUDIT_GIT" --work-tree=. add -A
  git --git-dir="$AUDIT_GIT" --work-tree=. diff --numstat --cached HEAD \
      -- . ':(exclude).pc' ':(exclude)debian/changelog' \
    | awk -F'\t' 'BEGIN{OFS="\t"}
        { a=$1; r=$2; if(a=="-")a="bin"; if(r=="-")r="bin"; print a,r,$3 }' \
    | LC_ALL=C sort -t"$(printf '\t')" -k3,3
}

# Provenance header written on top of a baseline when it is blessed.
audit_stamp(){
  echo "# trisquel golden manifest"
  echo "# package:      $PACKAGE"
  echo "# blessed-by:   ${DEBEMAIL:-unknown}"
  echo "# blessed-at:   $(date -Iseconds)"
  echo "# upstream:     ${UPSTREAM:-?} (${UPSTREAMRELEASE:-?})  helper-version: ${VERSION:-?}"
  echo "# blessed-with: AUDIT_BLESS=1"
  echo "# body-sha256:  $1"
}

# Return just the manifest body of a baseline file (skip the header).
audit_body(){ awk -v m="$AUDIT_MARK" 'seen{print} $0==m{seen=1}' "$1"; }

# Write a signed baseline from a fresh manifest.
audit_write_golden(){
  local out="$1" fresh="$2" h
  h="$(sha256sum < "$fresh" | cut -d' ' -f1)"
  mkdir -p "$(dirname "$out")"
  { audit_stamp "$h"; echo "$AUDIT_MARK"; cat "$fresh"; } > "$out"
}

# Compare a fresh manifest against the signed baseline; block on drift unless
# AUDIT_FORCE=1.  Used on xolotl (the gate).  No baseline yet => let it pass.
audit_gate(){
  local base="$1" fresh="$2" tmp
  if [ ! -f "$base" ]; then
    echo "> [audit] $PACKAGE: no baseline yet; run AUDIT_BLESS=1 to certify" 1>&2
    return 0
  fi
  tmp="$(mktemp)"; audit_body "$base" > "$tmp"
  if python3 "$AUDIT_LIBDIR/compare.py" "$tmp" "$fresh"; then
    rm -f "$tmp"; return 0
  fi
  rm -f "$tmp"
  if [ "${AUDIT_FORCE:-}" = 1 ]; then
    echo "> [audit] $PACKAGE: drift detected; AUDIT_FORCE=1 -> continuing (baseline untouched)" 1>&2
    return 0
  fi
  echo "E: [audit] $PACKAGE blocked by silent drift (source package not built)." 1>&2
  echo "   review it; if the change is legitimate: AUDIT_BLESS=1 bash make-$PACKAGE" 1>&2
  exit 1
}

# Close the audit: build the manifest, then either bless (write baseline) or
# gate (compare).  Called from the top of package(), before quilt applies
# patches, so the diff is the helper's effect only.
audit_end(){
  [ -n "${AUDIT_GIT:-}" ] || return 0
  local fresh; fresh="$(mktemp)"
  audit_manifest > "$fresh"
  rm -rf "$(dirname "$AUDIT_GIT")"
  if [ "${AUDIT_BLESS:-}" = 1 ]; then
    audit_write_golden "$AUDIT_GOLDEN/$PACKAGE/manifest.tsv" "$fresh"
    echo "> [audit] baseline signed: DATA/golden/$PACKAGE/manifest.tsv" 1>&2
  else
    audit_gate "$AUDIT_GOLDEN/$PACKAGE/manifest.tsv" "$fresh"
  fi
  rm -f "$fresh"
}
