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
# Verify the standalone quilt in this directory.
#
#   sums     the bundled files match SHA256SUMS and nothing else is under
#            etc/ or usr/ (offline)
#   archive  SHA256SUMS matches the official Trisquel .deb, following the
#            signed chain InRelease -> Packages.gz -> .deb (network, or --deb)
#   output   the bundled quilt gives the same output, exit status and tree
#            (files, modes and .pc/ metadata), byte for byte, as the system
#            quilt, for the call helpers/config makes and for the other
#            common commands; also with system quilt hidden when unshare is
#            available (needs the system quilt)
#
# Usage: verify.sh [all|sums|archive|output] [--deb FILE] [--keyring FILE] [--keep]
#   --deb FILE      check a local .deb instead of downloading it
#   --keyring FILE  keyring for InRelease (default: Trisquel archive keyring)
#   --keep          keep the work directory with the generated trees and logs
#
# Exit status is 0 only if no check failed. Skipped checks are listed.

set -u -o pipefail

here=$(dirname "$(readlink -f "$0")")
KEYRING=/usr/share/keyrings/trisquel-archive-keyring.gpg
DEB=""
KEEP=false
MODE=all

field(){ sed -n "s/^$1: //p" "$here/SOURCE"; }

# Same locale as helpers/config, made strict so no translation can differ.
export LANG=C LC_TIME=C LC_ALL=C
unset LANGUAGE LESS QUILT_PAGER QUILTRC QUILT_DIR

# fixture DIR: a small source tree with a debian/patches series that covers
# a plain change, an offset hunk, a new file, a removed file and a -p0 patch.
fixture(){
    local s=$1/src i
    mkdir -p "$s/debian/patches" "$s/sub"
    for i in $(seq 1 20); do echo "line $i"; done > "$s/f1"
    printf 'alpha\nbeta\ngamma\n' > "$s/f2"
    printf 'one\ntwo\n' > "$s/sub/f3"
    printf 'to be removed\n' > "$s/todelete"
    chmod 0755 "$s/sub/f3"
    cat > "$s/debian/patches/01-change.patch" <<'EOF'
Description: plain change
Author: Trisquel GNU/Linux developers <trisquel-devel@listas.trisquel.info>

--- a/f1
+++ b/f1
@@ -1,5 +1,5 @@
 line 1
 line 2
-line 3
+line 3 changed
 line 4
 line 5
EOF
    cat > "$s/debian/patches/02-offset.patch" <<'EOF'
Description: hunk that applies with an offset
--- a/f1
+++ b/f1
@@ -8,7 +8,7 @@
 line 10
 line 11
 line 12
-line 13
+line 13 changed
 line 14
 line 15
 line 16
EOF
    cat > "$s/debian/patches/03-newfile.patch" <<'EOF'
--- /dev/null
+++ b/sub/new.txt
@@ -0,0 +1,2 @@
+new file
+second line
EOF
    cat > "$s/debian/patches/04-delete.patch" <<'EOF'
--- a/todelete
+++ /dev/null
@@ -1 +0,0 @@
-to be removed
EOF
    cat > "$s/debian/patches/05-p0.patch" <<'EOF'
--- f2
+++ f2
@@ -1,3 +1,4 @@
 alpha
 beta
+beta and a half
 gamma
EOF
    cat > "$s/debian/patches/99-fail.patch" <<'EOF'
--- a/sub/f3
+++ b/sub/f3
@@ -1,2 +1,2 @@
 not
-there
+at all
EOF
    cat > "$s/debian/patches/extra.patch" <<'EOF'
--- a/sub/f3
+++ b/sub/f3
@@ -1,2 +1,3 @@
 one
 two
+three
EOF
    printf '# comment line\n01-change.patch\n02-offset.patch\n03-newfile.patch\n04-delete.patch\n05-p0.patch -p0\n' \
        > "$s/debian/patches/series"
}

# manifest DIR: path, type, mode and content hash of everything in DIR.
manifest(){
    (cd "$1" && find . -mindepth 1 -printf '%P\t%y\t%m\t%l\n' | LC_ALL=C sort |
        while IFS=$'\t' read -r p t m l; do
            if [ "$t" = f ]; then
                printf '%s\t%s\t%s\t%s\n' "$p" "$t" "$m" "$(sha256sum < "$p" | cut -d' ' -f1)"
            else
                printf '%s\t%s\t%s\t%s\n' "$p" "$t" "$m" "$l"
            fi
        done)
}

# Each scenario runs in DIR/src with QUILT... as the quilt command and logs
# every command, its output and its exit status to DIR.log.
scenario_config(){
    # The exact calls of package() in helpers/config.
    if [ -f debian/patches/series ]; then
        grep -q '[a-z]' debian/patches/series || : > debian/patches/series
    fi
    grep -qv '^#' debian/patches/series 2>/dev/null && step "$@" push -a
    step "$@" push -a
}

scenario_fail(){
    echo 99-fail.patch >> debian/patches/series
    step "$@" push -a
    step "$@" applied
    step "$@" unapplied
}

scenario_commands(){
    step "$@" push -a
    step "$@" pop -a
    step "$@" push 2
    step "$@" top
    step "$@" next
    step "$@" previous
    step "$@" applied
    step "$@" unapplied
    step "$@" series -v
    step "$@" files
    step "$@" header 01-change.patch
    step "$@" push -a
    step "$@" new 06-new.patch
    step "$@" add f2
    printf 'delta\n' >> f2
    step "$@" refresh
    step "$@" diff -P 06-new.patch
    printf 'epsilon\n' >> f2
    step "$@" refresh
    step "$@" import -P 07-imported.patch debian/patches/extra.patch
    step "$@" push
    step "$@" rename -P 07-imported.patch 07-renamed.patch
    step "$@" pop
    step "$@" delete 07-renamed.patch
    step "$@" pop -a
    step "$@" push -a
    step "$@" pu
    step "$@" re
    step "$@" nosuchcommand
}

step(){
    local rc
    echo "\$ quilt ${*:2}"
    "$@" < /dev/null 2>&1
    rc=$?
    echo "exit=$rc"
}

# run_scenario DIR NAME QUILT...
run_scenario(){
    local dir=$1 name=$2
    shift 2
    mkdir -p "$dir/home"
    (
        cd "$dir/src" || exit 1
        export HOME="$dir/home" QUILT_PATCHES=debian/patches TMPDIR="$dir/home"
        "scenario_$name" "$@"
    ) > "$dir.log" 2>&1
    manifest "$dir/src" > "$dir.manifest"
}

# Internal: run the bundled quilt with system quilt hidden.
if [ "${1:-}" = __isolated ]; then
    if [ -d /usr/share/quilt ]; then
        mount --bind "$2/empty" /usr/share/quilt || exit 1
    fi
    for f in /usr/bin/quilt /etc/quilt.quiltrc; do
        if [ -e "$f" ]; then
            mount --bind /dev/null "$f" || exit 1
        fi
    done
    # Not command -v: bash also reports a non-executable file found in PATH.
    if [ -e /usr/share/quilt/scripts/patchfns ] || [ -x /usr/bin/quilt ] ||
       [ -s /etc/quilt.quiltrc ]; then
        echo "system quilt still visible" >&2
        exit 1
    fi
    run_scenario "$3" "$4" "$here/quilt"
    exit $?
fi

while [ $# -gt 0 ]; do
    case $1 in
        all|sums|archive|output) MODE=$1 ;;
        --deb) DEB=$(readlink -f "$2"); shift ;;
        --keyring) KEYRING=$2; shift ;;
        --keep) KEEP=true ;;
        -h|--help) sed -n '19,36p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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
    present=$(cd "$here" && find etc usr -type f -o -type l | sort)
    if [ "$listed" = "$present" ]; then
        pass "sums: no unlisted files under etc/ or usr/"
    else
        fail "sums: files under etc/ or usr/ do not match SHA256SUMS:"
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
    installed=$(dpkg-query -W -f='${Version}' quilt 2>/dev/null || true)
    if [ "$installed" = "$(field Version)" ]; then
        if (cd / && sha256sum --check --strict --quiet "$here/SHA256SUMS"); then
            pass "archive: bundled files are byte-identical to the installed quilt $installed"
        else
            fail "archive: installed quilt $installed differs from the bundled files"
        fi
    else
        skip "archive: installed quilt is '${installed:-none}', not $(field Version); no local comparison"
    fi
}

# compare NAME REF OTHER LABEL: logs and manifests must be identical.
compare(){
    local name=$1 ref=$2 other=$3 label=$4 ok=true
    if ! cmp -s "$ref.log" "$other.log"; then
        ok=false
        fail "output: $name: $label output differs from system quilt"
        diff -u "$ref.log" "$other.log" | sed 's/^/      /'
    fi
    if ! cmp -s "$ref.manifest" "$other.manifest"; then
        ok=false
        fail "output: $name: $label tree differs from system quilt"
        diff -u "$ref.manifest" "$other.manifest" | sed 's/^/      /'
    fi
    $ok
}

check_output(){
    local sysquilt name d ok
    sysquilt=$(command -v quilt || true)
    if [ -z "$sysquilt" ]; then
        skip "output: no system quilt to compare with (install quilt to run this check)"
        return
    fi
    echo "      system quilt: $sysquilt (quilt $(dpkg-query -W -f='${Version}' quilt 2>/dev/null || echo unknown)), patch $(patch --version | sed -n '1s/.* //p')"
    local isolated=false
    mkdir -p "$work/empty"
    if unshare -rm true 2>/dev/null; then
        isolated=true
    else
        skip "output: unshare not available, cannot hide system quilt for the isolated run"
    fi
    for name in config fail commands; do
        d="$work/out/$name"
        mkdir -p "$d"
        fixture "$d/system"
        fixture "$d/bundled"
        run_scenario "$d/system" "$name" "$sysquilt"
        run_scenario "$d/bundled" "$name" "$here/quilt"
        ok=true
        compare "$name" "$d/system" "$d/bundled" bundled || ok=false
        if $isolated; then
            fixture "$d/isolated"
            if ! unshare -rm "$0" __isolated "$work" "$d/isolated" "$name"; then
                ok=false
                fail "output: $name: bundled quilt failed with system quilt hidden (see $d/isolated.log)"
            else
                compare "$name" "$d/system" "$d/isolated" "bundled (system quilt hidden)" || ok=false
            fi
        fi
        if $ok; then
            pass "output: $name: byte-identical to system quilt$($isolated && echo ', also with system quilt hidden')  [$(grep -c '^\$ quilt' "$d/system.log") commands, log sha256 $(sha256sum < "$d/system.log" | cut -c1-16), tree sha256 $(sha256sum < "$d/system.manifest" | cut -c1-16)]"
        fi
    done
}

echo "standalone quilt: $(field Package) $(field Version) ($here)"
echo "date: $(date -u +'%Y-%m-%d %H:%M:%S UTC'), host: $(uname -n), mode: $MODE"
case $MODE in
    all) check_sums; check_archive; check_output ;;
    sums) check_sums ;;
    archive) check_archive ;;
    output) check_output ;;
esac
echo "result: $passed passed, $failed failed, $skipped skipped"
[ "$failed" -eq 0 ]
