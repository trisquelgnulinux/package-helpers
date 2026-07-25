#!/usr/bin/env python3
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
# Compare a signed baseline manifest (known-good, e.g. 24.04) against a fresh
# one produced on the next upstream (e.g. 26.04).  Used by the gate on Xolotl;
# it is NOT used when freezing baselines on Ecne.
#
# Manifest line format:  added <TAB> removed <TAB> path
# Flags:
#   DROPPED  a file the helper used to change is no longer touched (edit no-op)
#   SHRUNK   same file, effect magnitude fell below `shrink` ratio (default .5)
#   NEW      a file touched now but not before (informational, not a failure)
# Exit non-zero if any DROPPED or SHRUNK is found.

import sys


def load(path):
    effect = {}
    with open(path) as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line or line.startswith("#") or line.startswith("---"):
                continue
            parts = line.split("\t")
            if len(parts) != 3:
                continue
            a, r, p = parts
            a = 0 if a in ("-", "bin") else int(a)
            r = 0 if r in ("-", "bin") else int(r)
            effect[p] = a + r
    return effect


def main():
    base = load(sys.argv[1])
    new = load(sys.argv[2])
    shrink = float(sys.argv[3]) if len(sys.argv) > 3 else 0.5
    problems = 0
    for path in sorted(base):
        if path not in new:
            print(f"DROPPED  {path}  ({base[path]} -> 0)")
            problems += 1
        elif base[path] > 0 and new[path] <= base[path] * shrink:
            print(f"SHRUNK   {path}  ({base[path]} -> {new[path]})")
            problems += 1
    for path in sorted(new):
        if path not in base:
            print(f"NEW      {path}  (0 -> {new[path]})")
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()
