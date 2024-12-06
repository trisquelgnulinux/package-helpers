#! /usr/bin/python3
#
# Script to parse Mirrors.masterlist file for python-apt template
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

import re
import argparse

# Set arguments and read input file
parser = argparse.ArgumentParser(description="Parse Mirrors.masterlist")
parser.add_argument(
    "file",
    help="Path to the Mirrors.masterlist file")
parser.add_argument(
    "--country",
    "-c",
    help="Filter by country (e.g., AU, BR, CA)",
    default=None)
args = parser.parse_args()

with open(args.file, 'r') as file:
    input_text = file.read()

# Split file by blocks per "Site:"
blocks = re.split(r'(?=Site:\s+)', input_text)
filtered_blocks = [
    block.strip()
    for block in blocks
    if block.strip().startswith("Site:")
]

# Process block country and site
mirrors = {}
for block in blocks:
    country_match = re.search(r'Country:\s+(\w{2})\b', block)
    country = country_match.group(1) if country_match else None

    site_match = re.search(r'Site:\s+(\S+)', block)
    site = site_match.group(1) if site_match else None

    if not country or not site:
        continue

    https_matches = re.findall(r"Archive-https:\s+(\S+)", block)
    http_matches = re.findall(r"Archive-http:\s+(\S+)", block)

    https_urls = [f"https://{site}{path}" for path in https_matches]
    http_urls = [f"http://{site}{path}" for path in http_matches]

    # Save data in dict
    if country not in mirrors:
        mirrors[country] = {}
    mirrors[country][site] = {"https": https_urls, "http": http_urls}

# Print output
for country, sites in sorted(mirrors.items()):
    if args.country and country != args.country:
        continue

    valid_sites = {
        site: urls for site, urls in sites.items() 
        if urls["https"] or urls["http"]
    }
    if not valid_sites:
        continue

    print(f"#LOC:{country}")
    for site, urls in valid_sites.items():
        for url in urls["https"]:
            print(url)
        for url in urls["http"]:
            print(url)
