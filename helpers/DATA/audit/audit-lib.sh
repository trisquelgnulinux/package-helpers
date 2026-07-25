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

# Print the upstream version apt would fetch, WITHOUT downloading the tarball,
# so freeze.sh makes an incremental comparation against the baseline's # upstream-version.
audit_probe(){
  local srcarg dsc ver
  if [ -n "${FIXED_VER:-}" ]; then srcarg="$PACKAGE=$FIXED_VER"; else srcarg="$PACKAGE"; fi
  dsc=$(apt-get source --print-uris --only-source "$srcarg" -c ${LOCAL_APT}/etc/apt.conf 2>/dev/null \
        | grep -oE "[^ '/]+_[^ ']+\.dsc" | head -1)
  ver=$(echo "$dsc" | sed 's/^[^_]*_//; s/\.dsc$//')
  # --print-uris gives URL-encoded names (+ -> %2b, ~ -> %7e); decode them.
  ver=$(printf '%b' "${ver//%/\\x}")
  echo "AUDIT_PROBE_VERSION=$ver"
  exit 0
}

# Take the "before" snapshot: the tree the helper is about to transform,
# with upstream patches not yet applied, and config's own edits in place.
# Diffing this against audit_end isolates the helper's own effect.
audit_begin(){
  [ -n "${AUDIT_REACHED:-}" ] && : > "$AUDIT_REACHED"
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
  # Who ran the freeze: the git email (git config user.email) of
  # the commiter, falls back to "unknown" if none is configured.
  local blesser
  blesser="${AUDIT_BLESSER:-$(git config user.email 2>/dev/null || git config user.name 2>/dev/null)}"
  echo "# trisquel golden manifest"
  echo "# package:      $PACKAGE"
  echo "# blessed-by:   ${blesser:-unknown}"
  echo "# blessed-at:   $(date -Iseconds)"
  echo "# upstream:     ${UPSTREAM:-?} (${UPSTREAMRELEASE:-?})  helper-version: ${VERSION:-?}"
  # epoch stripped so it compares equal to the probe (.dsc filenames drop it)
  echo "# upstream-version: $(echo "${UPSTREAMVERSION:-?}" | sed 's/^[0-9]*://')"
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

# Monitor: compare the fresh effect against the baseline and set AUDIT_VERDICT
# displays a greppable "audit: ..." line that audit_report prints at the end of
# the run.  It NEVER blocks the build: it only reports, graded by severity
# (ok / minor / DRIFT).  The one exception is the version-transition gate T12>T13
audit_evaluate(){
  local base="$1" fresh="$2" tmp diff d s n
  if [ ! -f "$base" ]; then
    AUDIT_VERDICT="audit: no baseline yet (create with AUDIT_BLESS=1)"
    return 0
  fi
  tmp="$(mktemp)"; audit_body "$base" > "$tmp"
  diff=$(python3 "$AUDIT_LIBDIR/compare.py" "$tmp" "$fresh" || true)
  rm -f "$tmp"
  d=$(printf '%s\n' "$diff" | grep -c '^DROPPED' || true)
  s=$(printf '%s\n' "$diff" | grep -c '^SHRUNK' || true)
  n=$(printf '%s\n' "$diff" | grep -c '^NEW' || true)
  if [ "$d" -gt 0 ] || [ "$s" -gt 0 ]; then
    AUDIT_VERDICT="audit: DRIFT — dropped=$d shrunk=$s new=$n  (review: git diff -- DATA/golden/$PACKAGE)"
    if [ "${AUDIT_STRICT:-}" = 1 ] && [ "${AUDIT_FORCE:-}" != 1 ]; then
      audit_report
      echo "E: [audit] $PACKAGE blocked by drift (AUDIT_STRICT set)." 1>&2
      exit 1
    fi
  elif [ "$n" -gt 0 ]; then
    AUDIT_VERDICT="audit: minor — new=$n file(s) now touched  (review: git diff -- DATA/golden/$PACKAGE)"
  else
    AUDIT_VERDICT="audit: OK, no changes vs baseline"
  fi
}

# Print the verdict as one greppable line.  Called from config's package(), at
# the very end -- next to "source package built" and the distro-match notes,
# which is where the eye lands when a helper run finishes.
audit_report(){
  [ -n "${AUDIT_VERDICT:-}" ] && echo "> ${AUDIT_VERDICT}"
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
  if [ "${AUDIT_BLESS:-}" = 1 ]; then
    audit_write_golden "$AUDIT_GOLDEN/$PACKAGE/manifest.tsv" "$fresh"
    AUDIT_VERDICT="audit: baseline signed (DATA/golden/$PACKAGE)"
  else
    audit_evaluate "$AUDIT_GOLDEN/$PACKAGE/manifest.tsv" "$fresh"
  fi
  rm -f "$fresh"
}
