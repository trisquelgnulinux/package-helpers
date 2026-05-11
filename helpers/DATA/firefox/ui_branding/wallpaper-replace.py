#    Copyright (C) 2026       Luis Guzman <ark@switnet.org>
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

import json
import hashlib
import os
import time
import argparse
import sys

def calculate_sha256_hash(file_path):
    """
    Calculates the SHA-256 hash of a physical file.
    """
    sha256_hash = hashlib.sha256()
    with open(file_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def build_step(config_path, output_path):
    """
    Step 1: Reads config.json, processes the data, and creates build.json.
    """
    print(f"--- Step 1: Building standalone artifact ---")

    if not os.path.exists(config_path):
        print(f"ERROR: Configuration file '{config_path}' not found.")
        sys.exit(1)

    with open(config_path, 'r', encoding='utf-8') as f:
        config = json.load(f)

    build_data = {}

    for item in config.get('replacements',):
        item_id = item.get('id_to_replace')
        image_path = item.get('local_image_path')
        theme = item.get('theme', '').strip()

        if not image_path or not os.path.exists(image_path):
            print(f"WARNING: Local image not found at '{image_path}' for ID {item_id}. Skipping.")
            continue

        file_size_bytes = os.path.getsize(image_path)
        sha256_hash = calculate_sha256_hash(image_path)

        # Get the real file name (e.g., 'trisquel-aramo.webp')
        real_file_name = os.path.basename(image_path)

        # Create the "disguised" file name to bypass Mozilla's strict schema validation
        disguised_file_name = real_file_name.replace('.webp', '.avif')

        # Create a 100% schema-compliant entry masking the webp as an avif
        build_data[item_id] = {
            "title": real_file_name.replace('.webp', ''),
            "theme": theme,
            "attachment": {
                "hash": sha256_hash,
                "size": file_size_bytes,
                "filename": disguised_file_name,
                "location": f"main-workspace/newtab-wallpapers-v2/{disguised_file_name}",
                "mimetype": "image/avif" # Masking the mime type for the validator
            }
        }

        # Check if the wallpaper is an "abe" one, to position logo accordingly
        if "abe" in real_file_name.lower():
            build_data[item_id]["background_position"] = "bottom right"

        # Make sure dark theme is used on trisquel-ecne & trisquel-aramo images
        if "trisquel-ecne" in real_file_name.lower() or "trisquel-aramo" in real_file_name.lower():
            build_data[item_id]["theme"] = "dark"

        print(f"Processed: {real_file_name} -> Masked as: {disguised_file_name} -> ID: {item_id}")

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(build_data, f, indent=2, ensure_ascii=False)

    print(f"\nSUCCESS: Generated standalone artifact at '{output_path}'.")

def replace_step(source_path, target_path):
    """
    Step 2: Injects the build.json data into the target Firefox JSON database.
    """
    print(f"\n--- Step 2: Injecting into target JSON ---")

    if not os.path.exists(source_path):
        print(f"ERROR: Build source file '{source_path}' not found.")
        sys.exit(1)

    if not os.path.exists(target_path):
        print(f"ERROR: Target JSON file '{target_path}' not found.")
        sys.exit(1)

    with open(source_path, 'r', encoding='utf-8') as f:
        build_data = json.load(f)

    with open(target_path, 'r', encoding='utf-8') as f:
        target_db = json.load(f)

    current_timestamp = int(time.time() * 1000)
    modified_count = 0

    for item in target_db.get('data',):
        item_id = item.get('id')

        if item_id in build_data:
            new_data = build_data[item_id]

            # Wipe old custom keys if they exist from previous tests
            item.pop('wallpaperUrl', None)

            # Apply schema-compliant data
            item['attachment'] = new_data['attachment']
            item['title'] = new_data['title']
            item['schema'] = current_timestamp
            item['last_modified'] = current_timestamp

            if new_data.get('theme'):
                item['theme'] = new_data['theme']

            # Apply background_position if it exists in build_data
            if new_data.get('background_position'):
                item['background_position'] = new_data['background_position']

            print(f"Updated ID: {item_id} with file '{new_data['attachment']['filename']}'")
            modified_count += 1

    if modified_count > 0:
        target_db['timestamp'] = current_timestamp
        with open(target_path, 'w', encoding='utf-8') as f:
            json.dump(target_db, f, indent=2, ensure_ascii=False)
        print(f"\nSUCCESS: Modified {modified_count} entries in '{target_path}'.")
    else:
        print("\nWARNING: No matching IDs found in the target JSON to replace.")

def main():
    parser = argparse.ArgumentParser(description="Firefox Newtab Wallpaper Injection Tool")
    parser.add_argument('--config', type=str, nargs='?', const='./config.json', help="Step 1: Path to config.json.")
    parser.add_argument('--replace', type=str, help="Step 2: Path to target Firefox JSON file to be modified.")
    parser.add_argument('--source', type=str, default='./build.json', help="Step 2: Path to the standalone build.json.")

    args = parser.parse_args()

    if not args.config and not args.replace:
        parser.print_help()
        sys.exit(1)

    if args.config: build_step(args.config, './build.json')
    if args.replace: replace_step(args.source, args.replace)

if __name__ == "__main__":
    main()
