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
# Verify the standalone rename in this directory.
#
#   sums     the bundled files match SHA256SUMS and nothing else is under
#            usr/ (offline)
#   archive  SHA256SUMS matches the official Trisquel .deb, following the
#            signed chain InRelease -> Packages.gz -> .deb (network, or --deb)
#   output   the bundled rename gives the same output, exit status and tree
#            (files, modes and contents), byte for byte, as the system
#            rename, for the calls the helpers make (direct and through
#            xargs) and for the common options; also with system rename
#            hidden when unshare is available, where the xargs calls also
#            find bin/rename through PATH as the helpers/config hook does
#            (needs the system rename)
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
unset LANGUAGE

# fixture DIR: a small tree with the names the helpers rename.
fixture(){
    local s=$1/src
    mkdir -p "$s/debian.master/config" "$s/debian.hwe-7.0/config" "$s/debian"
    echo 'CONFIG_VERSION_SIGNATURE=y' > "$s/debian.master/config/config.common.ubuntu"
    echo 'CONFIG_LOCALVERSION=""' > "$s/debian.hwe-7.0/config/config.common.ubuntu"
    echo '# annotations' > "$s/debian.hwe-7.0/config/annotations"
    echo 'Source: kubuntu-settings' > "$s/debian/control"
    echo 'etc/kubuntu' > "$s/debian/kubuntu-settings.install"
    echo '#!/bin/sh' > "$s/debian/kubuntu-settings.postinst"
    chmod 0755 "$s/debian/kubuntu-settings.postinst"

    mkdir -p "$s/tree/ubuntu-theme/sub" "$s/tree/kubuntu-icons" "$s/tree/plain"
    echo logo > "$s/tree/ubuntu-theme/ubuntu-logo.png"
    echo text > "$s/tree/ubuntu-theme/sub/ubuntu.txt"
    echo svg > "$s/tree/kubuntu-icons/kubuntu.svg"
    echo plain > "$s/tree/plain/file.txt"
    echo space > "$s/tree/with space ubuntu.txt"

    mkdir -p "$s/opt/dir-ubuntu"
    echo a > "$s/opt/ubuntu.txt"
    echo old > "$s/opt/x-old"
    echo new > "$s/opt/x-new"
    echo lower > "$s/opt/lower.txt"
    echo f > "$s/opt/dir-ubuntu/ubuntu-f"
    echo list > "$s/opt/list-ubuntu"
    echo null > "$s/opt/null-ubuntu"
    # cafe with e acute, in UTF-8; written with octal escapes to keep this
    # file ASCII.
    echo cafe > "$s/opt/$(printf 'caf\303\251.txt')"
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

step(){
    local rc
    echo "\$ rename ${*:2}"
    "$@" < /dev/null 2>&1
    rc=$?
    echo "exit=$rc"
}

# step_in INPUT RENAME ARGS...: like step, with INPUT (printf format) as stdin.
step_in(){
    local rc input=$1
    shift
    echo "\$ printf '$input' | rename ${*:2}"
    # shellcheck disable=SC2059
    printf "$input" | "$@" 2>&1
    rc=$?
    echo "exit=$rc"
}

# step_x LABEL FIND... -- ARGS...: find FIND... | sort | xargs RENAME ARGS...,
# as the helpers do (sorted, so the order does not depend on the filesystem).
step_x(){
    local rc label=$1 f=()
    shift
    while [ "$1" != -- ]; do f+=("$1"); shift; done
    shift
    echo "\$ $label"
    find "${f[@]}" | LC_ALL=C sort | xargs "${RENAME[@]}" "$@" 2>&1
    rc=$?
    echo "exit=$rc"
}

# Each scenario runs in DIR/src with RENAME... as the rename command and logs
# every command, its output and its exit status to DIR.log.
scenario_linux(){
    # The exact call of the make-linux* helpers, then again when nothing
    # matches the glob any more.
    step "$@" s/ubuntu/trisquel/ debian.*/config/config.common.ubuntu
    step "$@" s/ubuntu/trisquel/ debian.*/config/config.common.ubuntu
    # make-kubuntu-settings
    step "$@" s/kubuntu/triskel/ debian/*
}

scenario_xargs(){
    RENAME=("$@")
    cd tree || return 1
    # make-plymouth, make-budgie-artwork and others: directories first, so
    # the nested ones fail, then files.
    step_x 'find -type d | sort | xargs rename s/ubuntu/trisquel/g' -type d -- s/ubuntu/trisquel/g
    step_x 'find -type f | sort | xargs rename s/ubuntu/trisquel/g' -type f -- s/ubuntu/trisquel/g
    # make-ubiquity, make-kubuntu-settings
    step_x "find -name '*kubuntu*' | sort | xargs rename s/kubuntu/triskel/" -name '*kubuntu*' -- s/kubuntu/triskel/
    # Nothing found: xargs still runs rename once, which reads names from
    # its stdin (/dev/null under xargs).
    step_x "find -name '*nomatch*' | sort | xargs rename s/x/y/" -name '*nomatch*' -- s/x/y/
}

scenario_options(){
    cd opt || return 1
    step "$@" -n s/ubuntu/trisquel/ ubuntu.txt
    step "$@" -v s/ubuntu/trisquel/ ubuntu.txt
    step "$@" s/old/new/ x-old
    step "$@" -f s/old/new/ x-old
    step "$@" -d s/ubuntu/trisquel/ dir-ubuntu/ubuntu-f
    step "$@" y/a-z/A-Z/ lower.txt
    step "$@" -u utf8 's/\x{e9}/e/' "$(printf 'caf\303\251.txt')"
    step_in 'list-ubuntu\n' "$@" s/ubuntu/trisquel/
    # Not -v here: with names from stdin it prints a GLOB address, which
    # changes on every run.
    step_in 'null-ubuntu\0' "$@" -0 s/ubuntu/trisquel/
    step "$@" s/missing/x/ no-such-file
    step "$@" 's/(/x/' ubuntu.txt
    step "$@" --no-such-option s/a/b/ ubuntu.txt
    step "$@" -h
}

# run_scenario DIR NAME RENAME...
run_scenario(){
    local dir=$1 name=$2
    shift 2
    mkdir -p "$dir/home"
    (
        cd "$dir/src" || exit 1
        export HOME="$dir/home" TMPDIR="$dir/home"
        "scenario_$name" "$@"
    ) > "$dir.log" 2>&1
    manifest "$dir/src" > "$dir.manifest"
}

# Internal: run the bundled rename with system rename hidden.
# Args: WORK DIR NAME direct|path
if [ "${1:-}" = __isolated ]; then
    if [ -d /usr/share/perl5/File/Rename ]; then
        mount --bind "$2/empty" /usr/share/perl5/File/Rename || exit 1
    fi
    for f in /usr/share/perl5/File/Rename.pm /usr/bin/file-rename; do
        if [ -e "$f" ]; then
            mount --bind /dev/null "$f" || exit 1
        fi
    done
    if perl -MFile::Rename -e1 2>/dev/null || [ -x /usr/bin/file-rename ] ||
       [ -s /usr/bin/rename ]; then
        echo "system rename still visible" >&2
        exit 1
    fi
    if [ "$5" = path ]; then
        # As the helpers/config hook does: bin/ appended to PATH, rename
        # called by name.
        PATH="$PATH:$here/bin"
        run_scenario "$3" "$4" rename
    else
        run_scenario "$3" "$4" "$here/bin/rename"
    fi
    exit $?
fi

while [ $# -gt 0 ]; do
    case $1 in
        all|sums|archive|output) MODE=$1 ;;
        --deb) DEB=$(readlink -f "$2"); shift ;;
        --keyring) KEYRING=$2; shift ;;
        --keep) KEEP=true ;;
        -h|--help) sed -n '19,38p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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
    installed=$(dpkg-query -W -f='${Version}' rename 2>/dev/null || true)
    if [ "$installed" = "$(field Version)" ]; then
        if (cd / && sha256sum --check --strict --quiet "$here/SHA256SUMS"); then
            pass "archive: bundled files are byte-identical to the installed rename $installed"
        else
            fail "archive: installed rename $installed differs from the bundled files"
        fi
    else
        skip "archive: installed rename is '${installed:-none}', not $(field Version); no local comparison"
    fi
}

# compare NAME REF OTHER LABEL: logs and manifests must be identical.
compare(){
    local name=$1 ref=$2 other=$3 label=$4 ok=true
    if ! cmp -s "$ref.log" "$other.log"; then
        ok=false
        fail "output: $name: $label output differs from system rename"
        diff -u "$ref.log" "$other.log" | sed 's/^/      /'
    fi
    if ! cmp -s "$ref.manifest" "$other.manifest"; then
        ok=false
        fail "output: $name: $label tree differs from system rename"
        diff -u "$ref.manifest" "$other.manifest" | sed 's/^/      /'
    fi
    $ok
}

# isolated D NAME direct|path: run the scenario with system rename hidden
# and compare it with the system run.
isolated(){
    local d=$1 name=$2 how=$3 label="bundled (system rename hidden)"
    [ "$how" = path ] && label="bundled (system rename hidden, found through PATH)"
    fixture "$d/isolated-$how"
    if ! unshare -rm "$0" __isolated "$work" "$d/isolated-$how" "$name" "$how"; then
        fail "output: $name: bundled rename failed with system rename hidden (see $d/isolated-$how.log)"
        return 1
    fi
    compare "$name" "$d/system" "$d/isolated-$how" "$label"
}

check_output(){
    local sysrename name d ok extra
    sysrename=$(command -v file-rename || true)
    if [ -z "$sysrename" ]; then
        skip "output: no system rename to compare with (install rename to run this check)"
        return
    fi
    echo "      system rename: $sysrename (rename $(dpkg-query -W -f='${Version}' rename 2>/dev/null || echo unknown)), perl $(perl -e 'print $^V')"
    local isolated=false
    mkdir -p "$work/empty"
    if unshare -rm true 2>/dev/null; then
        isolated=true
    else
        skip "output: unshare not available, cannot hide system rename for the isolated run"
    fi
    for name in linux xargs options; do
        d="$work/out/$name"
        mkdir -p "$d"
        fixture "$d/system"
        fixture "$d/bundled"
        run_scenario "$d/system" "$name" "$sysrename"
        run_scenario "$d/bundled" "$name" "$here/bin/rename"
        ok=true extra=""
        compare "$name" "$d/system" "$d/bundled" bundled || ok=false
        if $isolated; then
            isolated "$d" "$name" direct || ok=false
            extra=", also with system rename hidden"
            if [ "$name" = xargs ]; then
                isolated "$d" "$name" path || ok=false
                extra="$extra, also found through PATH"
            fi
        fi
        if $ok; then
            pass "output: $name: byte-identical to system rename$extra  [$(grep -c '^\$ ' "$d/system.log") commands, log sha256 $(sha256sum < "$d/system.log" | cut -c1-16), tree sha256 $(sha256sum < "$d/system.manifest" | cut -c1-16)]"
        fi
    done
}

echo "standalone rename: $(field Package) $(field Version) ($here)"
echo "date: $(date -u +'%Y-%m-%d %H:%M:%S UTC'), host: $(uname -n), mode: $MODE"
case $MODE in
    all) check_sums; check_archive; check_output ;;
    sums) check_sums ;;
    archive) check_archive ;;
    output) check_output ;;
esac
echo "result: $passed passed, $failed failed, $skipped skipped"
[ "$failed" -eq 0 ]
