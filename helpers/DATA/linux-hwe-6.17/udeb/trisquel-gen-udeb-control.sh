#!/bin/bash
# trisquel-gen-udeb-control.sh
# Generates the udeb stanzas for debian/control using kernel-wedge.

set -e

ARCH=$1
DEBIAN=$2
VERSION=$3
ABINUM=$4
CONTROL_FILE=$5

if [ -z "$ARCH" ] || [ -z "$DEBIAN" ] || [ -z "$VERSION" ] || [ -z "$ABINUM" ] || [ -z "$CONTROL_FILE" ]; then
    echo "Usage: $0 <arch> <debian_dir> <upstream_version> <abinum> <control_file>"
    exit 1
fi

# Prevent duplicate udeb stanzas if the script is called multiple times
if grep -q '^Package-Type: udeb' "$CONTROL_FILE"; then
    echo ">> Trisquel: Udeb packages already present in $CONTROL_FILE. Skipping generation."
    exit 0
fi

echo ">> Trisquel: Generating udeb control stanzas for $ARCH..."

# Create an isolated environment for kernel-wedge
KWTMP="debian/build/kw-d-i-$ARCH"
rm -rf "$KWTMP"
mkdir -p "$KWTMP"

# Copy the static d-i configuration for processing
cp -a "$DEBIAN/d-i/." "$KWTMP/"

# Filter kernel-versions to process only the current architecture
grep -E "^$ARCH[[:space:]]" "$KWTMP/kernel-versions" > "$KWTMP/kernel-versions.new"
mv -f "$KWTMP/kernel-versions.new" "$KWTMP/kernel-versions"

# Generate control data and append to the main control file
KW_DEFCONFIG_DIR="$KWTMP" KW_CONFIG_DIR="$KWTMP" LANG=C \
    kernel-wedge gen-control "$VERSION-$ABINUM" | \
    grep-dctrl -FArchitecture "$ARCH" >> "$CONTROL_FILE"

echo ">> Trisquel: Udeb control generation completed."
