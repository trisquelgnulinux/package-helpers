#!/bin/bash
#
#    Copyright (C) 2026  Luis Guzman <ark@switnet.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
# Shared bits for the audit scripts: the manifest marker and the body
# extractor, defined in ONE place so the format lives in a single file.
# Sourced by audit-lib.sh, verify.sh and bless.sh.

AUDIT_MARK='--- manifest ---'

# Return just the manifest body of a baseline file (everything after the mark).
audit_body(){ awk -v m="$AUDIT_MARK" 'seen{print} $0==m{seen=1}' "$1"; }
