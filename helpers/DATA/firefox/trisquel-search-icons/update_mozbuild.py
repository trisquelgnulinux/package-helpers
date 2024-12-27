#! /usr/bin/python3
#
# Script to add trisquel's icons on search engine options.
#
#    Copyright (C) 2024 Luis Guzmán <ark@switnet.org>
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

# File path
moz_build_path = "services/settings/dumps/main/moz.build"

# New entries to add
new_entries = [
    "search-config-icons/b99ed276-9557-4492-8bbb-d59826381893",
    "search-config-icons/b99ed276-9557-4492-8bbb-d59826381893.meta.json",
    "search-config-icons/b5fd21a8-e369-477f-a3f2-b47a370f9030",
    "search-config-icons/b5fd21a8-e369-477f-a3f2-b47a370f9030.meta.json",
]

# Read the moz.build file
with open(moz_build_path, "r") as file:
    lines = file.readlines()

# Locate the section for `search-config-icons`
start_idx = None
for idx, line in enumerate(lines):
    if "FINAL_TARGET_FILES.defaults.settings.main[\"search-config-icons\"] += [" in line:
        start_idx = idx
        break

if start_idx is None:
    raise RuntimeError("Could not find the 'search-config-icons' section in moz.build")

# Extract existing entries
start_idx += 1
end_idx = start_idx
while end_idx < len(lines) and lines[end_idx].strip() != "]":
    end_idx += 1

current_entries = [line.strip().strip(",") for line in lines[start_idx:end_idx]]

# Combine and sort all entries
all_entries = sorted(set(current_entries + [f'"{entry}"' for entry in new_entries]))

# Replace the section in moz.build
lines[start_idx:end_idx] = [f"        {entry},\n" for entry in all_entries]

# Write the updated content back to the file
with open(moz_build_path, "w") as file:
    file.writelines(lines)

print("> Added trisquel's search engine icons to 'moz.build'")
