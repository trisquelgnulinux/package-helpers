#!/bin/bash
#
#    Copyright (C) 2026 Luis Guzman <ark@switnet.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#
# Verify the standalone dch in this directory.
#
#   sums     the bundled files match SHA256SUMS and nothing else is under usr/
#            (offline)
#   archive  SHA256SUMS matches the official Trisquel .deb, following the
#            signed chain InRelease -> Packages.gz -> .deb (network, or --deb)
#   output   the bundled dch writes the same debian/changelog, byte for byte,
#            as the system dch, using the same calls helpers/config makes;
#            also with system devscripts hidden when unshare is available
#            (needs the system dch)
#
# Usage: verify.sh [all|sums|archive|output] [--deb FILE] [--keyring FILE] [--keep]
#   --deb FILE      check a local .deb instead of downloading it
#   --keyring FILE  keyring for InRelease (default: Trisquel archive keyring)
#   --keep          keep the work directory with the generated changelogs
#
# Exit status is 0 only if no check failed. Skipped checks are listed.

set -u -o pipefail

here=$(dirname "$(readlink -f "$0")")
KEYRING=/usr/share/keyrings/trisquel-archive-keyring.gpg
DEB=""
KEEP=false
MODE=all

field(){ sed -n "s/^$1: //p" "$here/SOURCE"; }

# The calls below mirror changelog_multiline() and changelog() in helpers/config.
export LANG=C LC_TIME=C LC_ALL=C
export DEBEMAIL=trisquel-devel@listas.trisquel.info
export DEBFULLNAME="Trisquel GNU/Linux developers"
MSG=$'Removed ubuntu references in debian/libnewt0.52.install\nSecond line of the change log entry'

sample_changelog(){
    mkdir -p "$1/debian"
    cat > "$1/debian/changelog" <<'EOF'
newt (0.52.24-2ubuntu2) noble; urgency=medium

  * No-change rebuild for CVE-2024-3094

 -- Steve Langasek <steve.langasek@ubuntu.com>  Sun, 31 Mar 2024 08:10:07 +0000

newt (0.52.24-2ubuntu1) noble; urgency=medium

  * Previous entry

 -- Someone <someone@example.org>  Mon, 01 Jan 2024 00:00:00 +0000
EOF
}

# run_sequence DIR DIST FORCE DCH...
run_sequence(){
    local dir=$1 dist=$2 force=$3
    shift 3
    (
        cd "$dir" || exit 1
        version="$(dpkg-parsechangelog --show-field Version)trisquel1"
        "$@" $force -v "$version" -D "$dist" "" || exit 1
        while IFS= read -r line || [ -n "$line" ]; do
            "$@" -a "$line" || exit 1
        done <<< "$MSG"
        "$@" $force -r "" || exit 1
        /bin/sed "/-- Trisquel/s/.*/ -- Trisquel GNU\/Linux developers <trisquel-devel@listas.trisquel.info>  $FIXED_DATE/" -i debian/changelog
    ) < /dev/null > "$dir.log" 2>&1
}

# Internal: run the bundled dch with system devscripts and distro-info hidden.
if [ "${1:-}" = __isolated ]; then
    for d in /usr/share/perl5/Devscripts /usr/share/perl5/Debian; do
        [ -d "$d" ] && { mount --bind "$2/empty" "$d" || exit 1; }
    done
    if [ -e /usr/bin/debchange ]; then
        mount --bind /dev/null /usr/bin/debchange || exit 1
    fi
    if perl -MDevscripts::Compression -e1 2>/dev/null; then
        echo "system Devscripts modules still visible" >&2
        exit 1
    fi
    FIXED_DATE=$3
    run_sequence "$4" "$5" "$6" "$here/dch"
    exit $?
fi

while [ $# -gt 0 ]; do
    case $1 in
        all|sums|archive|output) MODE=$1 ;;
        --deb) DEB=$(readlink -f "$2"); shift ;;
        --keyring) KEYRING=$2; shift ;;
        --keep) KEEP=true ;;
        -h|--help) sed -n '19,35p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
    shift
done

work=$(mktemp -d)
if $KEEP; then
    echo "work directory: $work"
else
    trap 'rm -rf "${work:?}"' EXIT
fi

passed=0 failed=0 skipped=0
pass(){ echo "PASS: $*"; passed=$((passed + 1)); }
fail(){ echo "FAIL: $*"; failed=$((failed + 1)); }
skip(){ echo "SKIP: $*"; skipped=$((skipped + 1)); }

fetch(){
    local _
    for _ in 1 2 3; do
        curl -fsS -m 300 -o "$2" "$1" && return 0
        sleep 2
    done
    return 1
}

check_sums(){
    if (cd "$here" && sha256sum --check --strict --quiet SHA256SUMS); then
        pass "sums: bundled files match SHA256SUMS"
    else
        fail "sums: bundled files differ from SHA256SUMS"
    fi
    local listed present
    listed=$(awk '{print $2}' "$here/SHA256SUMS" | sort)
    present=$(cd "$here" && find usr -type f -o -type l | sort)
    if [ "$listed" = "$present" ]; then
        pass "sums: no unlisted files under usr/"
    else
        fail "sums: files under usr/ do not match SHA256SUMS:"
        diff <(echo "$listed") <(echo "$present") | sed 's/^/      /'
    fi
}

# Print "<sha256> <filename>" for PACKAGE=VERSION from a signed suite, or nothing.
signed_index_entry(){
    local suite=$1 archive component pkg ver d
    archive=$(field Archive) component=$(field Component)
    pkg=$(field Package) ver=$(field Version)
    d="$work/archive/$suite"
    mkdir -p "$d"
    fetch "$archive/dists/$suite/InRelease" "$d/InRelease" || {
        echo "      $suite: cannot download InRelease" >&2; return 1; }
    gpgv --keyring "$KEYRING" --output "$d/Release" "$d/InRelease" 2> "$d/gpgv.log" || {
        echo "      $suite: InRelease signature NOT valid with $KEYRING" >&2
        sed 's/^/      /' "$d/gpgv.log" >&2
        return 1; }
    echo "      $suite: InRelease signed by $(sed -n 's/.*using [A-Z]* key //p; s/.*usando [A-Z]* clave //p' "$d/gpgv.log" | head -1)" >&2
    local want
    want=$(awk -v f="$component/binary-amd64/Packages.gz" \
        '/^SHA256:/{s=1; next} /^[^ ]/{s=0} s && $3 == f {print $1}' "$d/Release")
    [ -n "$want" ] || { echo "      $suite: no Packages.gz in Release" >&2; return 1; }
    fetch "$archive/dists/$suite/$component/binary-amd64/Packages.gz" "$d/Packages.gz" || {
        echo "      $suite: cannot download Packages.gz" >&2; return 1; }
    [ "$(sha256sum < "$d/Packages.gz" | cut -d' ' -f1)" = "$want" ] || {
        echo "      $suite: Packages.gz does NOT match the signed Release" >&2; return 1; }
    # Read the whole index (no early exit): with pipefail, zcat dying of
    # SIGPIPE would make this fail even when the entry was found.
    zcat "$d/Packages.gz" | awk -v p="$pkg" -v v="$ver" '
        function flush() { if (pp == p && vv == v) print sha, fn; pp = vv = sha = fn = "" }
        /^$/          { flush() }
        /^Package: /  { pp = $2 }
        /^Version: /  { vv = $2 }
        /^SHA256: /   { sha = $2 }
        /^Filename: / { fn = $2 }
        END           { flush() }'
}

check_archive(){
    local sha fn deb entry="" suite
    sha=$(field SHA256) fn=$(field Filename)
    if [ -n "$DEB" ]; then
        deb=$DEB
        echo "      using local $deb (checked against the hash pinned in SOURCE)"
    else
        command -v curl > /dev/null || { skip "archive: curl not installed (use --deb FILE)"; return; }
        command -v gpgv > /dev/null || { fail "archive: gpgv not installed"; return; }
        [ -r "$KEYRING" ] || { fail "archive: keyring $KEYRING not found (use --keyring FILE)"; return; }
        for suite in $(field Suites); do
            entry=$(signed_index_entry "$suite") && [ -n "$entry" ] && break
            entry=""
        done
        if [ -n "$entry" ]; then
            if [ "$entry" = "$sha $fn" ]; then
                pass "archive: $(field Package) $(field Version) is in the signed $suite index with the SHA256 pinned in SOURCE"
            else
                fail "archive: signed $suite index says '$entry', SOURCE says '$sha $fn'"
                return
            fi
        else
            echo "      $(field Version) not found in any signed index (Suites: $(field Suites)); checking the pinned hash only"
        fi
        deb="$work/$(basename "$fn")"
        fetch "$(field Archive)/$fn" "$deb" || { fail "archive: cannot download $fn"; return; }
    fi
    if [ "$(sha256sum < "$deb" | cut -d' ' -f1)" = "$sha" ]; then
        pass "archive: .deb SHA256 matches SOURCE"
    else
        fail "archive: .deb SHA256 does NOT match SOURCE"
        return
    fi
    mkdir -p "$work/deb"
    dpkg-deb -x "$deb" "$work/deb" || { fail "archive: cannot extract $deb"; return; }
    if (cd "$work/deb" && sha256sum --check --strict --quiet "$here/SHA256SUMS"); then
        pass "archive: bundled files are byte-identical to the files in the official .deb"
    else
        fail "archive: bundled files differ from the official .deb"
    fi

    local installed
    installed=$(dpkg-query -W -f='${Version}' devscripts 2>/dev/null || true)
    if [ "$installed" = "$(field Version)" ]; then
        if (cd / && sha256sum --check --strict --quiet "$here/SHA256SUMS"); then
            pass "archive: bundled files are byte-identical to the installed devscripts $installed"
        else
            fail "archive: installed devscripts $installed differs from the bundled files"
        fi
    else
        skip "archive: installed devscripts is '${installed:-none}', not $(field Version); no local comparison"
    fi
}

check_output(){
    local sysdch dist force name ok
    sysdch=$(command -v dch || true)
    if [ -z "$sysdch" ]; then
        skip "output: no system dch to compare with (install devscripts to run this check)"
        return
    fi
    echo "      system dch: $sysdch (devscripts $(dpkg-query -W -f='${Version}' devscripts 2>/dev/null || echo unknown))"
    FIXED_DATE=$(date +'%a, %d %b %Y %T %z')
    local isolated=false
    mkdir -p "$work/empty"
    if unshare -rm true 2>/dev/null; then
        isolated=true
    else
        skip "output: unshare not available, cannot hide system devscripts for the isolated run"
    fi
    for dist in ecne ecne-security ecne-backports; do
        for force in "" --force-distribution; do
            name="$dist${force:+ $force}"
            d="$work/out/$dist${force:+-force}"
            mkdir -p "$d"
            sample_changelog "$d/system"
            sample_changelog "$d/bundled"
            run_sequence "$d/system" "$dist" "$force" "$sysdch" || { fail "output: $name: system dch failed (see $d/system.log)"; continue; }
            run_sequence "$d/bundled" "$dist" "$force" "$here/dch" || { fail "output: $name: bundled dch failed (see $d/bundled.log)"; continue; }
            ok=true
            if ! cmp -s "$d/system/debian/changelog" "$d/bundled/debian/changelog"; then
                ok=false
                fail "output: $name: bundled differs from system dch"
                diff -u "$d/system/debian/changelog" "$d/bundled/debian/changelog" | sed 's/^/      /'
            fi
            if $isolated; then
                sample_changelog "$d/isolated"
                if ! unshare -rm "$0" __isolated "$work" "$FIXED_DATE" "$d/isolated" "$dist" "$force"; then
                    ok=false
                    fail "output: $name: bundled dch failed with system devscripts hidden (see $d/isolated.log)"
                elif ! cmp -s "$d/system/debian/changelog" "$d/isolated/debian/changelog"; then
                    ok=false
                    fail "output: $name: bundled (system devscripts hidden) differs from system dch"
                    diff -u "$d/system/debian/changelog" "$d/isolated/debian/changelog" | sed 's/^/      /'
                fi
            fi
            if $ok; then
                pass "output: $name: byte-identical to system dch$($isolated && echo ', also with system devscripts hidden')  [sha256 $(sha256sum < "$d/system/debian/changelog" | cut -c1-16)]"
            fi
        done
    done
}

echo "standalone devscripts: $(field Package) $(field Version) ($here)"
echo "date: $(date -u +'%Y-%m-%d %H:%M:%S UTC'), host: $(uname -n), mode: $MODE"
case $MODE in
    all) check_sums; check_archive; check_output ;;
    sums) check_sums ;;
    archive) check_archive ;;
    output) check_output ;;
esac
echo "result: $passed passed, $failed failed, $skipped skipped"
[ "$failed" -eq 0 ]
